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
├── mappings/                     CSV → RDF (TARQL CONSTRUCTs)
│   ├── people.rq
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
make load         # load /training (asserted) and /training-inferred (+ closure) into Fuseki
make reveal       # the reasoning reveal — same plain query, with vs without the closure
make clean        # wipe build/
```

## The bridge

`bio:wasBornIn` connects a `family:Person` to a `geo:Town`. Once both
sides exist in one graph, queries can traverse from a person, through
their birth town, up the transitive `geo:isLocatedIn` chain, to a country
or continent. That is the whole point — knowledge graphs become useful
when domains link.

## Reasoning — the reveal

`geo:isLocatedIn` is declared `owl:TransitiveProperty` in the ontology. There
are two ways to get the transitive closure (London → UK → Europe):

- **Property path** — query with `geo:isLocatedIn+`. Works on the asserted
  graph, no reasoner. That's `people-born-in-europe.rq`.
- **Materialised closure** — assert every reachable `(a → c)` up front, then
  query with plain `geo:isLocatedIn`. `make infer` builds the closure with an
  `arq` CONSTRUCT (`infer-locatedin.rq`) — exactly what a forward-chaining
  reasoner does, made explicit — and `make load` puts it in `/training-inferred`.

`make reveal` runs the *same plain query* (`people-born-in-europe-plain.rq`)
against both Fuseki datasets: nothing from `/training`, the full answer from
`/training-inferred`. That gap is what a reasoner buys you.

(We materialise the closure rather than run a live reasoner: it's reliable,
transparent — `build/closure.ttl` is the inferred triples, right there to
inspect — and free of Jena's InfModel-over-a-mutated-store quirks.)

## What's deliberately missing

- **SPADE.** The Module 7 deck shows a `spade run steps/` step. SPADE is
  an SP-internal pipeline tool; the lab substitutes a plain SPARQL
  `CONSTRUCT` (via `arq`) for the same purpose. Same shape, no internal
  dependency.
- **mustrd test layer.** Tests will be added as part of the broader CI rig.
