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
5. Optionally **load into GraphDB** and watch the reasoner materialise the transitive closure of `geo:isLocatedIn`.

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
│   ├── people-born-in-europe.rq
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
make load         # POST the graph to the local GraphDB `training` repo
make clean        # wipe build/
```

## The bridge

`bio:wasBornIn` connects a `family:Person` to a `geo:Town`. Once both
sides exist in one graph, queries can traverse from a person, through
their birth town, up the transitive `geo:isLocatedIn` chain, to a country
or continent. That is the whole point — knowledge graphs become useful
when domains link.

## Reasoning

`geo:isLocatedIn` is declared `owl:TransitiveProperty` in the ontology.

- Locally (with `arq` / pyshacl): the queries use `geo:isLocatedIn+`
  (a SPARQL property path) to compute the closure on the fly.
- In GraphDB: the `training` repo runs with `rdfsplus-optimized` ruleset,
  which materialises the transitive closure. Queries use plain
  `geo:isLocatedIn` and get the same answer.

The lab shows both routes so trainees can compare.

## What's deliberately missing

- **SPADE.** The Module 7 deck shows a `spade run steps/` step. SPADE is
  an SP-internal pipeline tool; the lab substitutes a plain SPARQL
  `CONSTRUCT` (via `arq`) for the same purpose. Same shape, no internal
  dependency.
- **mustrd test layer.** Tests will be added as part of the broader CI rig.
