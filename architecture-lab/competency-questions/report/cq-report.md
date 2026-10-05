# Ontologies Report

## Coverage Report

### Ontologies

Coverage below is measured against this ontology:

- [../ontology/lab-ontology.ttl](../../ontology/lab-ontology.ttl) — `https://semanticpartners.com/data/sptr-lab/ontology` — Minimal ontology for the architecture lab: people, places, and the bio:wasBornIn bridge between them.


### Term Coverage

**Overall: 7/7 terms exercised by the tests = 100%**

**By a competency question: 7/7 = 100%**


_(8 declared; 1 structural term(s) excluded from the denominator — see below.)_

A term counts as **covered** when a passing test **populates it in input data** (as an instance type or asserted predicate) — whether or not a query also names it. A term named *only* in a query but never instantiated is **not** covered (the test can still pass without it); it is flagged **query-only**. Ontology declarations alone never count.

Classes are arranged by `rdfs:subClassOf` (indented `↳` under their superclass); a class's properties sit beneath it (`▸`, by `rdfs:domain`). A term exercised by tests has a `•` sub-row per test, showing what *that* test contributes (input data / SPARQL).

| Term | Kind | <abbr title="A passing test asserts the term in its given data — as an rdf:type object or an asserted predicate">In input data</abbr> | <abbr title="A passing test's SPARQL query names the term as an IRI (from the parsed query algebra; comments ignored)">In SPARQL</abbr> | <abbr title="Not instantiated or queried, but load-bearing: domain/range of a used property, superclass of a used class, or a metadata property. Excluded from the coverage %">Structural</abbr> | <abbr title="covered = populated in a passing test's input data; query-only = named by a query but never instantiated (not covered); structural = excluded; unused = untouched">Test Term Coverage</abbr> | <abbr title="Whether a competency question — not just any test — exercises the term">CQ Term Coverage</abbr> |
|------|------|:---:|:---:|:---:|:---:|:---:|
| family:Person | class | ✅ | ✅ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;▸ bio:birthYear | property | ✅ | ❌ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;▸ bio:wasBornIn | property | ✅ | ✅ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ❌ | · | | |
| geo1:GeographicRegion | class | ❌ | ❌ | ✅ | 🔧 structural | 🔧 structural |
| &nbsp;&nbsp;&nbsp;&nbsp;▸ geo1:isLocatedIn | property | ✅ | ✅ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ geo1:Continent | class | ✅ | ✅ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ✅ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ geo1:Country | class | ✅ | ❌ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;↳ geo1:Town | class | ✅ | ❌ | · | ✅ covered | ✅ covered |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | | ✅ | ❌ | · | | |
| &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;• [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | | ✅ | ❌ | · | | |

#### How to read this table

The **In input data**, **In SPARQL** and **Structural** columns show *where* a term is exercised, classifying every term into a role. **Coverage is data-based**: a term must be populated in some passing test's input data to count.

| Data | SPARQL | Structural | Role | Counts? |
|:---:|:---:|:---:|------|---------|
| ✅ | ✅ | | **fully exercised** | ✅ **covered** — populated in the data *and* queried (strongest evidence) |
| ✅ | ❌ | | **data-only** | ✅ **covered** — instances exist; a property-path query may consume them by IRI without naming the class (to be confirmed by mutation testing). Candidate for a dedicated query. |
| ❌ | ✅ | | **query-only** | ❌ **not covered** — matched by a query (e.g. via `rdfs:subClassOf*`) but never instantiated; the test can pass without it. Often a sign the query leans on a TBox axiom that belongs in the ontology. |
| ❌ | ❌ | ✅ | **structural** | 🔧 **excluded** — not instantiated/queried, but load-bearing: domain/range of a used property, superclass of a used class, or a metadata property (annotation/ontology property). Good for documentation & inferencing. |
| ❌ | ❌ | | **unused** | ❌ **not covered** — not exercised by any test, nor structural to one |

A term's **In input data** / **In SPARQL** columns aggregate across *all* tests, so a term whose data and SPARQL come from *different* tests still shows ✅/✅. The `•` **sub-rows** break that down: one per test, with that test's own input-data / SPARQL contribution — so you can see whether a single test exercises the term end to end. **CQ Term Coverage** applies the same verdict (✅ covered / ❌ query only / ❌ unused / 🔧 structural) but counting **only competency questions** — so a term a non-CQ test covers still reads *❌ unused* here (no CQ pins it down). Compare it with Test Term Coverage to see what only the non-CQ tests reach.

### Not covered by any test

_none — every declared term is covered or structural_

### Structural terms (excluded from coverage)

Not directly exercised, but load-bearing — they define the structure of the terms the tests use:

- geo1:GeographicRegion (class) — domain of geo:isLocatedIn; range of geo:isLocatedIn; superclass of geo:Continent



## Competency Questions Report

### Competency Questions

_3 competency questions — 2 with a test, 1 without._

| Competency Question | Test | Test Status | Coverage Status |
|---------------------|------|-------------|-----------------|
| In which year was each person born? | — | — | — |
| Which people were born in Europe? | [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl)<br>[people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) | ✅ passed<br>✅ passed | ✅ passed<br>✅ passed |
| Which places are in Europe? | [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) | ✅ passed | ✅ passed |


### Not used by any CQ

_none — every declared term is exercised by a competency question or is structural_

### Per competency question

🧩 **requires ontology to pass** marks a CQ whose query only matches its data through the ontology's class hierarchy (it queries a class but the data holds instances of a *subclass*), so the ontology must be loaded as an input dataset for the test to pass.


- **In which year was each person born?**
  - _no linked test_

- **Which people were born in Europe?**
  - test: [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) — _passed_
  - test: [people-born-in-europe.mustrd.ttl](../specs/people-born-in-europe.mustrd.ttl) — _passed_
  - in data:  bio:birthYear, bio:wasBornIn, family:Person, geo1:Continent, geo1:Country, geo1:Town, geo1:isLocatedIn
  - in query: bio:wasBornIn, family:Person, geo1:isLocatedIn

- **Which places are in Europe?**
  - test: [places-in-continent.mustrd.ttl](../specs/places-in-continent.mustrd.ttl) — _passed_
  - in data:  bio:birthYear, bio:wasBornIn, family:Person, geo1:Continent, geo1:Country, geo1:Town, geo1:isLocatedIn
  - in query: geo1:Continent, geo1:isLocatedIn
