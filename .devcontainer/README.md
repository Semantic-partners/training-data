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

## Running a cohort in Codespaces (trainer / org-owner setup)

Trainees do **not** need personal Codespaces hours. The org pays, capped — and
each trainee creates the Codespace on **this org repo**, not a fork. (A fork in a
personal account bills that person, and personal accounts can be blocked for any
of several reasons — exhausted free tier, $0 budget, no card on file, or a
managed/EMU account with no free allowance. Don't rely on it for a delivery.)

**Before the course — org owner, once:**

1. **Org → Settings → Codespaces** — enable Codespaces for the org. Under the
   access policy, make sure **outside collaborators are allowed** to use it (not
   just members), and pick the machine type (2- or 4-core is plenty here).
2. **Org → Settings → Billing** — add a payment method and set a Codespaces
   **spending limit** (≈ $100 covers a cohort: ~10 people × ~8 h × 4-core ≈
   $50–60; idle Codespaces auto-stop).
3. Collect each trainee's **GitHub username**.
4. **This repo → Settings → Collaborators → Add people** — add each trainee.
   `training-data` is **public**, so they join as **outside collaborators** and
   **don't consume paid org seats** — only Codespaces usage is billed. **Read**
   access is enough to create a Codespace. (Alternatively: make a team in the org
   and grant it read here.)

**On the day — each trainee:**

1. Open **github.com/Semantic-partners/training-data** (the org repo — *not* a
   fork).
2. Green **Code → Codespaces → +** (create on `main`). Billed to Semantic
   Partners.
3. `cd architecture-lab && make load && make reveal`.

**After the course:**

- Remove the collaborators, and drop the Codespaces spending limit back to **$0**
  to stop any further spend.

**No-cloud fallback:** anyone who can run **Docker Desktop** locally can skip
Codespaces entirely — clone the repo, open in VS Code, "Reopen in Container".
Same devcontainer, zero GitHub billing. (Often blocked on locked-down corporate
laptops, hence org-billed Codespaces as the primary path.)
