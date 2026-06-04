#!/usr/bin/env bash
# One-shot tool sanity check after the dev container finishes building.
# Also waits for GraphDB to come up and creates a `training` repo (RDFS-Plus
# ruleset) so the pre-configured Mentor SPARQL connection works immediately.
set -uo pipefail

GRAPHDB_URL="${GRAPHDB_URL:-http://graphdb:7200}"

echo
echo "── Tool sanity check ─────────────────────────────"
printf "java        : "; java -version 2>&1 | head -n1
printf "python      : "; python3 --version
printf "riot (Jena) : "; riot --version 2>/dev/null | head -n1 || echo "MISSING"
printf "arq (Jena)  : "; command -v arq >/dev/null && echo "ok ($(command -v arq))" || echo "MISSING"
printf "tarql       : "; command -v tarql >/dev/null && echo "ok ($(command -v tarql))" || echo "MISSING"
printf "pyshacl     : "; python3 -c "import pyshacl; print(pyshacl.__version__)" 2>/dev/null || echo "MISSING"
printf "rdflib      : "; python3 -c "import rdflib; print(rdflib.__version__)" 2>/dev/null || echo "MISSING"
printf "morph-kgc   : "; python3 -c "import morph_kgc; print(morph_kgc.__version__)" 2>/dev/null || echo "MISSING"
printf "mustrd      : "; python3 -c "import mustrd" 2>/dev/null && echo "ok" || echo "MISSING"
echo

echo "── GraphDB ───────────────────────────────────────"
printf "Waiting for GraphDB at %s " "$GRAPHDB_URL"
for i in $(seq 1 60); do
    if curl -sf "$GRAPHDB_URL/rest/info/version" >/dev/null 2>&1; then
        echo " up"
        break
    fi
    printf "."
    sleep 2
done

if curl -sf "$GRAPHDB_URL/rest/info/version" >/dev/null 2>&1; then
    VERSION=$(curl -s "$GRAPHDB_URL/rest/info/version" | head -c 80)
    echo "GraphDB version: $VERSION"

    # Create the `training` repo if it doesn't already exist.
    if curl -sf "$GRAPHDB_URL/rest/repositories/training" >/dev/null 2>&1; then
        echo "Repo 'training' already exists — skipping create."
    else
        echo "Creating repo 'training' (RDFS-Plus reasoning) ..."
        if curl -sS -X POST \
            "$GRAPHDB_URL/rest/repositories" \
            -H "Content-Type: multipart/form-data" \
            -F "config=@.devcontainer/graphdb/training-repo-config.ttl" \
            -w "  HTTP %{http_code}\n" -o /tmp/graphdb-create.log; then
            cat /tmp/graphdb-create.log
        else
            echo "  Repo create failed (see /tmp/graphdb-create.log) — you can create one in the workbench."
        fi
    fi
else
    echo "GraphDB not reachable after 120s — start the compose stack manually or check logs."
fi
echo "──────────────────────────────────────────────────"
echo
echo "Try a SHACL lab end-to-end:"
echo "  pyshacl -s 'SHACL shapes/lab_1_sh_class.ttl' -d 'SHACL data graph/lab_1_sh_class.ttl' -f human"
echo
echo "GraphDB workbench: open forwarded port 7200 (see Ports panel)"
echo "Mentor already has a 'graphdb-local' connection pointing at:"
echo "  $GRAPHDB_URL/repositories/training"
echo
echo "Talk to GraphDB from the CLI:"
echo "  curl \"\$GRAPHDB_URL/repositories/training?query=SELECT+*+WHERE+%7B+%3Fs+%3Fp+%3Fo+%7D+LIMIT+5\""
