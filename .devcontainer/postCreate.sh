#!/usr/bin/env bash
# Print a one-shot tool sanity check. If anything fails, the trainee sees it
# the moment the container finishes building.
set -uo pipefail

echo
echo "── Tool sanity check ─────────────────────────────"
printf "java         : "; java -version 2>&1 | head -n1
printf "python       : "; python3 --version
printf "riot (Jena)  : "; riot --version 2>/dev/null | head -n1 || echo "MISSING"
printf "arq (Jena)   : "; command -v arq >/dev/null && echo "ok ($(command -v arq))" || echo "MISSING"
printf "fuseki       : "; ls /opt/fuseki/fuseki-server >/dev/null 2>&1 && echo "ok (/opt/fuseki/fuseki-server)" || echo "MISSING"
printf "tarql        : "; command -v tarql >/dev/null && echo "ok ($(command -v tarql))" || echo "MISSING"
printf "pyshacl      : "; python3 -c "import pyshacl; print(pyshacl.__version__)" 2>/dev/null || echo "MISSING"
printf "rdflib       : "; python3 -c "import rdflib; print(rdflib.__version__)" 2>/dev/null || echo "MISSING"
printf "morph-kgc    : "; python3 -c "import morph_kgc; print(morph_kgc.__version__)" 2>/dev/null || echo "MISSING"
printf "mustrd       : "; python3 -c "import mustrd" 2>/dev/null && echo "ok" || echo "MISSING"
echo "──────────────────────────────────────────────────"
echo
echo "Try a SHACL lab end-to-end:"
echo "  pyshacl -s 'SHACL shapes/lab_1_sh_class.ttl' -d 'SHACL data graph/lab_1_sh_class.ttl' -f human"
echo
echo "Start Fuseki (in-memory, /ds dataset) when you need a SPARQL endpoint:"
echo "  fuseki-server --mem /ds"
echo "  # then browse forwarded port 3030"
