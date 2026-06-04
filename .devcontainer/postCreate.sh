#!/usr/bin/env bash
# One-shot tool sanity check after the dev container finishes building.
set -uo pipefail

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
printf "GraphDB     : "
if curl -sf "${GRAPHDB_URL:-http://graphdb:7200}/rest/info/version" >/dev/null 2>&1; then
    echo "reachable at ${GRAPHDB_URL:-http://graphdb:7200} ($(curl -s ${GRAPHDB_URL:-http://graphdb:7200}/rest/info/version | head -c 60))"
else
    echo "not reachable yet (it may still be starting — wait ~30s and try again)"
fi
echo "──────────────────────────────────────────────────"
echo
echo "Try a SHACL lab end-to-end:"
echo "  pyshacl -s 'SHACL shapes/lab_1_sh_class.ttl' -d 'SHACL data graph/lab_1_sh_class.ttl' -f human"
echo
echo "GraphDB workbench: open forwarded port 7200 (see Ports panel)"
echo "  Create a repo with reasoning enabled to play with inferencing."
echo
echo "Talk to GraphDB from the CLI inside this container:"
echo "  curl \$GRAPHDB_URL/rest/info/version"
echo "  curl \"\$GRAPHDB_URL/repositories/<repo>?query=SELECT+*+WHERE+%7B+%3Fs+%3Fp+%3Fo+%7D+LIMIT+5\""
