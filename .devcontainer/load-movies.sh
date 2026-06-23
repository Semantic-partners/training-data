#!/usr/bin/env bash
# (Re)load the Day-1 "Intro to Knowledge Graphs" film/person graph into the
# writable /movies Fuseki dataset.
#
# Idempotent: PUT replaces the default graph, so re-run this any time to RESET
# the store after the INSERT/DELETE labs (deck module 4) have mutated it.
#
#   bash .devcontainer/load-movies.sh
set -uo pipefail

FUSEKI_URL="${FUSEKI_URL:-http://fuseki:3030}"
SEED="$(cd "$(dirname "$0")/.." && pwd)/rdf_movie_example.ttl"

printf "Loading %s into %s/movies (replace) ... " "$(basename "$SEED")" "$FUSEKI_URL"
if curl -fsS -X PUT -H "Content-Type: text/turtle" --data-binary "@$SEED" \
        "$FUSEKI_URL/movies/data?default" >/dev/null; then
    echo "ok"
else
    echo "FAILED — is Fuseki up? ($FUSEKI_URL)"
fi
