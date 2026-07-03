#!/usr/bin/env bash
# One-shot tool sanity check after the dev container finishes building, and a
# wait for Fuseki (the sibling triplestore) to come up. The `training` and
# `training-inferred` datasets are defined in fuseki/config.ttl, so there's
# nothing to create here — just load them with `make load`.
set -uo pipefail

FUSEKI_URL="${FUSEKI_URL:-http://fuseki:3030}"

echo
echo "── Tool sanity check ─────────────────────────────"
printf "java        : "; java -version 2>&1 | head -n1
printf "python      : "; python3 --version
printf "riot (Jena) : "; riot --version 2>/dev/null | head -n1 || echo "MISSING"
printf "arq (Jena)  : "; command -v arq >/dev/null && echo "ok ($(command -v arq))" || echo "MISSING"
printf "tarql       : "; command -v tarql >/dev/null && echo "ok ($(command -v tarql))" || echo "MISSING"
printf "pyshacl     : "; python3 -c "import pyshacl; print(pyshacl.__version__)" 2>/dev/null || echo "MISSING"
printf "rdflib      : "; python3 -c "import rdflib; print(rdflib.__version__)" 2>/dev/null || echo "MISSING"
printf "mustrd      : "; python3 -c "import mustrd" 2>/dev/null && echo "ok" || echo "MISSING"
echo

echo "── Fuseki ────────────────────────────────────────"
printf "Waiting for Fuseki at %s " "$FUSEKI_URL"
for i in $(seq 1 60); do
    if curl -sf "$FUSEKI_URL/$/ping" >/dev/null 2>&1; then
        echo " up"
        break
    fi
    printf "."
    sleep 2
done

if curl -sf "$FUSEKI_URL/$/ping" >/dev/null 2>&1; then
    echo "Datasets: /training, /training-inferred, /training-reasoned (architecture lab),"
    echo "          /movies (Day-1 Intro-to-KG labs)"
    # Day-1 labs should land in a populated store (querying/mutating, not ETL),
    # so auto-load the movie seed. The architecture-lab datasets stay manual
    # (`make load`) — loading IS that lab's lesson.
    bash "$(dirname "$0")/load-movies.sh"
else
    echo "Fuseki not reachable after 120s — start the compose stack manually or check logs."
fi
echo "──────────────────────────────────────────────────"
echo
echo "Try a SHACL lab end-to-end:"
echo "  pyshacl -s 'SHACL shapes/lab_1_sh_class_shape.ttl' -d 'SHACL data graph/lab_1_sh_class.ttl' -f human"
echo
echo "Day-1 Intro-to-KG SPARQL labs (movie data):"
echo "  • SELECT/ASK labs : Mentor against the file — FROM <workspace:/sparql_movie_examples.ttl>"
echo "  • INSERT/DELETE   : run against the /movies dataset (Fuseki UI on :3030, or the 'movies' Mentor connection)"
echo "  • Reset after mutating:  bash .devcontainer/load-movies.sh"
echo
echo "Build + load the architecture lab (Day 3), then see reasoning reveal itself:"
echo "  cd architecture-lab && make load && make reveal"
echo
echo "Fuseki UI: open forwarded port 3030 (see Ports panel)."
echo "Query from the CLI:"
echo "  curl -s \"\$FUSEKI_URL/training-inferred/sparql\" --data-urlencode 'query=SELECT * WHERE { ?s ?p ?o } LIMIT 5' -H 'Accept: text/csv'"
