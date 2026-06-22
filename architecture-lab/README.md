# Architecture lab — CSV → KG → query

End-to-end pipeline lab for Day 3 of the training. Two CSVs become an RDF
knowledge graph that joins **people** (from the Day-1 Family ontology) to
**places** (from the Day-1 Geospatial ontology) via a bridge predicate
`bio:wasBornIn`.

The lab is small on purpose. Each layer is one command, each step produces
a file you can inspect, and the whole thing reruns with `make all`.

## What you'll do

1. **Ingest two CSVs** (`csv/people.csv` and `csv/places.csv`) using **TARQL**.
2. **Merge** the raw triples with the **ontology** into one graph.
3. **Validate** with **SHACL** (pyshacl).
4. **Query** with **SPARQL** — cross-domain, transitive, the works.
5. **Load into Fuseki** and *reveal the reasoning*: the same plain query returns nothing against the asserted graph, but the full transitive closure of `geo:isLocatedIn` against `/training-inferred`.

## Files

```
architecture-lab/
├── csv/                          input
│   ├── people.csv
│   └── places.csv
├── mappings/                     CSV → RDF — a cookbook of recipes (see below)
│   ├── people.rq                 TARQL (SPARQL CONSTRUCT over CSV)
│   ├── people_rdflib.py          plain Python + rdflib
│   ├── people.yarrrml.yml        YARRRML — the friendly face of RML
│   ├── people.rml.ttl            RML (executed by rmlmapper)
│   ├── people.r2rml.ttl          R2RML over SQLite (executed by ontop)
│   ├── people_to_sqlite.py       loads people.csv into SQLite for R2RML
│   ├── people.properties         ontop JDBC connection
│   └── places.rq
├── ontology/
│   └── lab-ontology.ttl          minimal ontology, reuses geo:/family:
├── shapes/                       SHACL validation
│   ├── people.ttl
│   └── places.ttl
├── queries/                      SPARQL questions
│   ├── people-born-in-europe.rq        property-path form (geo:isLocatedIn+)
│   ├── people-born-in-europe-plain.rq  plain form — needs the materialised closure
│   ├── infer-locatedin.rq              materialises the transitive closure
│   └── places-in-continent.rq
├── tests/                        mustrd given/when/then specs
│   ├── infer-closure.mustrd.ttl       tests the closure enrichment step
│   └── mustrd-config.ttl
├── Makefile                      pipeline glue
└── README.md
```

## Run it

Inside the devcontainer (Codespace or local). From this directory:

```bash
make all          # ingest both CSVs, merge with ontology, run the cross-domain query
make validate     # run pyshacl against the merged graph
make places       # query the geographic side only
make infer        # materialise the transitive closure (build/graph-inferred.ttl)
make load         # load all three datasets: /training, /training-inferred (+ closure), /training-reasoned
make reveal       # the reasoning reveal — same plain query, three ways (none / materialised / live reasoner)
make test         # run the mustrd specs (given/when/then over the queries)
make clean        # wipe build/
```

## The bridge

`bio:wasBornIn` connects a `family:Person` to a `geo:Town`. Once both
sides exist in one graph, queries can traverse from a person, through
their birth town, up the transitive `geo:isLocatedIn` chain, to a country
or continent. That is the whole point — knowledge graphs become useful
when domains link.

## A mapping cookbook — same data, several ways

Getting CSV into RDF has no single right answer. This lab keeps a small
*cookbook* of recipes that all turn `people.csv` into the **same triples** — so
you can weigh the tools on equal ground and pick what fits your context, not
because a slide said so. We're painting a set of possibilities, not a mandate.

| Recipe | Tool | Reach for it when… | Status |
|---|---|---|---|
| `make people-tarql`  | TARQL — SPARQL CONSTRUCT over CSV | you already think in SPARQL; quick CSV → RDF | ✓ |
| `make people-rdflib` | plain Python + rdflib | code is what you have; the logic gets fiddly | ✓ |
| `make people-rml`    | RML / YARRRML (rmlmapper) | declarative mapping, many sources, an open standard | ✓ |
| `make people-r2rml`  | R2RML over SQLite (ontop) | the source is a *database*, not a file (pairs with OBDA) | ✓ |

`make cookbook` runs the recipes and diffs them as canonical N-Triples. It's a
**heads-up, not a pass/fail** — the differences are the lesson. The sharp one:
vanilla **RML percent-encodes** `New York` → `place/New%20York`, because core RML
has no string-replace (you'd need an FNML/FnO function); TARQL, rdflib and R2RML
all slug it to `New_York`. Same job, different tools, different *pains*. The
graph is the spec; the mapping is a choice — we're painting the possibilities,
not prescribing one.

(`make people-rml` lazy-fetches `rmlmapper.jar` into `build/` on first run —
Java's already here for Jena — so it doesn't bloat the image.)

## Reasoning — the reveal

`geo:isLocatedIn` is transitive: London → UK → Europe. There are **three** honest
ways to get that closure, and the lab runs all three against the *same plain
query* (`people-born-in-europe-plain.rq`) — a little cookbook of reasoning:

- **Property path** — query with `geo:isLocatedIn+`. No reasoner, no extra data;
  the *query* walks the chain. That's `people-born-in-europe.rq`, on `/training`.
- **Materialised closure** — assert every reachable `(a → c)` up front, then query
  with plain `geo:isLocatedIn`. `make infer` builds it with an `arq` CONSTRUCT
  (`infer-locatedin.rq`) — a forward-chaining reasoner made explicit; the inferred
  triples sit in `build/closure.ttl`, right there to read — and `make load` puts
  them in `/training-inferred`. *You* did the reasoning.
- **Live reasoner** — same asserted data, behind a Jena `GenericRuleReasoner`
  (`.devcontainer/fuseki/rules.txt`) on `/training-reasoned`. Plain
  `geo:isLocatedIn` works because the *engine* derives the closure itself, on
  load — no offline step.

`make reveal` runs the same plain query against `/training`, `/training-inferred`
and `/training-reasoned`: nothing from the first, the full answer from the other
two. The arc is the lesson — **no reasoning → you materialise it by hand → the
engine does it for you.** Same question, same answer, three mechanisms.

## What's deliberately missing

- **SPADE.** The Module 7 deck shows a `spade run steps/` step. SPADE is
  an SP-internal pipeline tool; the lab substitutes a plain SPARQL
  `CONSTRUCT` (via `arq`) for the same purpose. Same shape, no internal
  dependency.
- **mustrd test layer (started).** One worked example is in —
  `tests/infer-closure.mustrd.ttl` tests the closure enrichment step
  (`queries/infer-locatedin.rq`): given two hops, the CONSTRUCT must derive the
  third. Run it with `make test`. Fuller coverage lands with the CI rig.
