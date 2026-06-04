# Devcontainer — KG training tooling

Opens the repo with a pre-installed toolchain so trainees can run the labs without local setup.

Two services run under Docker Compose:
- **app** — the workspace container with CLI tools (Jena, TARQL, pyshacl, ...)
- **graphdb** — Ontotext GraphDB triplestore with the workbench on port `7200`

## Tools (in `app`)

| Tool | Use | Where |
|---|---|---|
| Apache Jena CLI | `riot`, `arq`, `sparql`, `shacl` — parsing, querying, validating | `/opt/jena/bin` |
| TARQL | SPARQL CONSTRUCT over CSV — quick CSV → RDF | `/opt/tarql/bin/tarql` |
| pyshacl | Python SHACL validator (used in the SHACL labs) | `pip` package |
| Morph-KGC | YARRRML / RML → RDF | `pip` package, run with `morph-kgc` |
| rdflib | Python RDF library | `pip` package |
| mustrd | RDF-aware test framework (for CI of lab solutions) | `pip` package |

Plus the [Mentor](https://marketplace.visualstudio.com/items?itemName=faubulous.mentor) VS Code extension for Turtle/SHACL editing.

## GraphDB

Reachable from inside the `app` container as `http://graphdb:7200` (env var: `$GRAPHDB_URL`).
Workbench is forwarded to port `7200` — open it from the Ports panel in VS Code / Codespaces.

Create a repository in the workbench with reasoning enabled (RDFS, OWL-Horst, OWL2-RL, etc.) to play with inferencing — the workbench shows asserted vs inferred triples and lets you switch profiles.

## Quick recipes

**Validate one SHACL lab** (lab 1 is the only one with a worked shape in this repo; you write the rest):

```bash
pyshacl -s "SHACL shapes/lab_1_sh_class.ttl" \
        -d "SHACL data graph/lab_1_sh_class.ttl" \
        -f human
```

**CSV → RDF with TARQL:**

```bash
tarql mapping.rq input.csv > out.ttl
```

**CSV → RDF with YARRRML via Morph-KGC:**

```bash
morph-kgc config.ini   # config.ini references the YARRRML mapping
```

**Talk to GraphDB from CLI:**

```bash
curl $GRAPHDB_URL/rest/info/version
curl "$GRAPHDB_URL/repositories/<repo>?query=SELECT+*+WHERE+%7B+%3Fs+%3Fp+%3Fo+%7D+LIMIT+5"
```

## Customising

The Dockerfile pins Jena, TARQL versions with `ARG`. The GraphDB image tag is pinned in `docker-compose.yml`. `postCreate.sh` runs once per container build to print a tool sanity check including GraphDB reachability.
