# training-data

## Querying Graphs with SPARQL
`sparql_movie_examples.ttl` — the film/person dataset for the Day-1 KG modules (representing data as graphs, and the SPARQL query/update labs). Solution for the first query in `sparql_query_solution.rq`.

The Day-1 labs split by what they need:

- **Query labs (SELECT / ASK / CONSTRUCT)** — run in **Mentor** straight against the
  file: `FROM <workspace:/sparql_movie_examples.ttl>`. No server needed.
- **Update labs (INSERT / DELETE)** — need a live triplestore (the point is to
  mutate, then re-query and see the change). The devcontainer serves a writable
  Fuseki dataset **`/movies`**, pre-loaded with `sparql_movie_examples.ttl` on start.
  Run them in the **Fuseki UI** (forwarded port 3030) with the endpoint set to
  **`/movies`** — it serves both queries and updates, so reads and writes share
  one endpoint. (Mentor is query-only; it can't run INSERT/DELETE.) **Reset** the
  data after mutating it: `bash .devcontainer/load-movies.sh`.

## SHACL
Individual data sets for SHACL labs. Solution for first SHACL lab. Examples of constraint components, helpful links.
