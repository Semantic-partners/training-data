# training-data

## Represeting data as graphs
Examples from this module in RDF format (Turtle).

## Querying Graphs with SPARQL
Data set needed for SPARQL queries in RDF format (Turtle). Solution for first query (.rq).

The Day-1 labs split by what they need:

- **Query labs (SELECT / ASK / CONSTRUCT)** — run in **Mentor** straight against the
  file: `FROM <workspace:/sparql_movie_examples.ttl>`. No server needed.
- **Update labs (INSERT / DELETE)** — need a live triplestore (the point is to
  mutate, then re-query and see the change). The devcontainer serves a writable
  Fuseki dataset **`/movies`**, pre-loaded with `sparql_movie_examples.ttl` on start.
  Run updates from the Fuseki UI (forwarded port 3030) or the `movies` Mentor
  connection. **Reset** the data after mutating it: `bash .devcontainer/load-movies.sh`.

## SHACL
Individual data sets for SHACL labs. Solution for first SHACL lab. Examples of constraint components, helpful links.
