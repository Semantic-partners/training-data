# Devcontainer — KG training tooling

Opens the repo with a pre-installed toolchain so trainees can run the labs without local setup.

Two services run under Docker Compose:
- **app** — the workspace container with CLI tools (Jena, TARQL, pyshacl, ...)
- **fuseki** — Apache Jena Fuseki triplestore on port `3030`, serving two
  datasets: `/training` (asserted) and `/training-inferred` (asserted +
  materialised closure). Free, no licence — unlike GraphDB 11, which now
  requires one even for its free tier.

## Tools (in `app`)

| Tool | Use | Where |
|---|---|---|
| Apache Jena CLI | `riot`, `arq`, `sparql`, `shacl` — parsing, querying, validating | `/opt/jena/bin` |
| TARQL | SPARQL CONSTRUCT over CSV — quick CSV → RDF | `/opt/tarql/bin/tarql` |
| pyshacl | Python SHACL validator (used in the SHACL labs) | `pip` package |
| rdflib | Python RDF library | `pip` package |
| mustrd | RDF-aware test framework (for CI of lab solutions) | `pip` package |

Plus the [Mentor](https://marketplace.visualstudio.com/items?itemName=faubulous.mentor) VS Code extension for Turtle/SHACL editing — pre-wired with two SPARQL connections (`/training`, `/training-inferred`).

## Fuseki

Reachable from inside the `app` container as `http://fuseki:3030` (env var: `$FUSEKI_URL`).
The UI is forwarded to port `3030` — open it from the Ports panel in VS Code / Codespaces.

Two datasets (defined in `fuseki/config.ttl`, both in-memory — reload each session):
- **`/training`** — the asserted graph. Transitive questions need a property path (`geo:isLocatedIn+`).
- **`/training-inferred`** — asserted graph plus the materialised transitive
  closure (computed offline by `make infer`), so plain `geo:isLocatedIn` works.

That pair *is* the reasoning demo — see `architecture-lab` (`make reveal`).

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

**Talk to Fuseki from the CLI:**

```bash
curl "$FUSEKI_URL/$/ping"
curl -s "$FUSEKI_URL/training-inferred/sparql" \
     --data-urlencode 'query=SELECT * WHERE { ?s ?p ?o } LIMIT 5' \
     -H 'Accept: text/csv'
```

## Customising

The Dockerfile pins Jena and TARQL versions with `ARG`. The Fuseki image tag is
pinned in `docker-compose.yml`; the datasets live in `fuseki/config.ttl` and
auth is wide-open via `fuseki/shiro.ini` (local throwaway container only).
`postCreate.sh` runs once per container build to print a tool sanity check and
wait for Fuseki.
