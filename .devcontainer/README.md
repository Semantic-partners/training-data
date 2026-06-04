# Devcontainer — KG training tooling

Opens the repo with a pre-installed toolchain so trainees can run the labs without local setup.

## Tools

| Tool | Use | Where |
|---|---|---|
| Apache Jena CLI | `riot`, `arq`, `sparql`, `shacl` — parsing, querying, validating | `/opt/jena/bin` |
| Apache Jena Fuseki | SPARQL endpoint server | `/opt/fuseki/fuseki-server`, port `3030` |
| TARQL | SPARQL CONSTRUCT over CSV — quick CSV → RDF | `/opt/tarql/bin/tarql` |
| pyshacl | Python SHACL validator (used in the SHACL labs) | `pip` package |
| Morph-KGC | YARRRML / RML → RDF | `pip` package, run with `morph-kgc` |
| rdflib | Python RDF library | `pip` package |
| mustrd | RDF-aware test framework (for CI of lab solutions) | `pip` package |

Plus the [Mentor](https://marketplace.visualstudio.com/items?itemName=faubulous.mentor) VS Code extension for Turtle/SHACL editing.

## Quick recipes

**Validate one SHACL lab** (lab 1 is the only one with a worked shape in this repo; you write the rest):

```bash
pyshacl -s "SHACL shapes/lab_1_sh_class.ttl" \
        -d "SHACL data graph/lab_1_sh_class.ttl" \
        -f human
```

**Spin up a Fuseki SPARQL endpoint** (in-memory):

```bash
fuseki-server --mem /ds
```

Then visit `http://localhost:3030` (Codespaces forwards the port automatically).

**Load data into Fuseki:**

```bash
fuseki-server --mem --file=mydata.ttl /ds
```

**CSV → RDF with TARQL:**

```bash
tarql mapping.rq input.csv > out.ttl
```

**CSV → RDF with YARRRML via Morph-KGC:**

```bash
morph-kgc config.ini  # config.ini points at the YARRRML mapping
```

## Customising

The Dockerfile pins Jena, Fuseki, TARQL versions with `ARG` so they're easy to bump. The `postCreate.sh` runs once per container build to print a tool sanity check.
