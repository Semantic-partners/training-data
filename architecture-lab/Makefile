# Architecture lab: CSV → triples → validate → query
#
# Builds the joined people+places knowledge graph from two CSVs,
# validates with SHACL, runs cross-domain SPARQL queries.
#
# Layers:
#   csv/  → mappings/  → build/raw.ttl
#                      + ontology/lab-ontology.ttl
#                                 → build/graph.ttl
#                                 → validation report
#                                 → query answers
#
# Targets:
#   make all       — build the graph and run the cross-domain query
#   make validate  — run SHACL against the graph
#   make query     — list people born in Europe (property-path form)
#   make places    — list places by continent
#   make infer     — materialise the transitive closure (build/graph-inferred.ttl)
#   make load      — load both graphs into Fuseki (/training and /training-inferred)
#   make reveal    — the reasoning reveal: plain geo:isLocatedIn, with vs without closure
#   make clean     — wipe build/

BUILD := build
FUSEKI_URL ?= http://fuseki:3030

PEOPLE_TTL   := $(BUILD)/people.ttl
PLACES_TTL   := $(BUILD)/places.ttl
GRAPH_TTL    := $(BUILD)/graph.ttl
INFERRED_TTL := $(BUILD)/graph-inferred.ttl
CLOSURE_TTL  := $(BUILD)/closure.ttl
REPORT_TTL   := $(BUILD)/shacl-report.ttl

.PHONY: all validate query places infer load reveal clean \
        people-tarql people-rdflib people-rml cookbook

all: query

$(BUILD):
	mkdir -p $@

# --- Layer 1: ingest each CSV with TARQL ---

$(PEOPLE_TTL): csv/people.csv mappings/people.rq | $(BUILD)
	tarql mappings/people.rq csv/people.csv > $@

$(PLACES_TTL): csv/places.csv mappings/places.rq | $(BUILD)
	tarql mappings/places.rq csv/places.csv > $@

# --- Layer 2: merge raw triples with the ontology into one graph ---

$(GRAPH_TTL): $(PEOPLE_TTL) $(PLACES_TTL) ontology/lab-ontology.ttl | $(BUILD)
	riot --formatted=ttl $^ > $@

# --- Layer 3: validate ---

validate: $(GRAPH_TTL) shapes/people.ttl shapes/places.ttl
	pyshacl -s shapes/people.ttl -s shapes/places.ttl -d $(GRAPH_TTL) -f human

# --- Layer 4: query (file-based, no server needed) ---

query: $(GRAPH_TTL)
	@echo "== People born in Europe =="
	arq --data $(GRAPH_TTL) --query queries/people-born-in-europe.rq

places: $(GRAPH_TTL)
	@echo "== Places by continent =="
	arq --data $(GRAPH_TTL) --query queries/places-in-continent.rq

# --- Layer 5: materialise the reasoning ---
#
# geo:isLocatedIn is owl:TransitiveProperty. A forward-chaining reasoner would
# assert every (a → c) reachable through the chain. We do exactly that with an
# arq property-path CONSTRUCT, then merge it back — so the inferred graph can be
# queried with PLAIN geo:isLocatedIn (no `+`). This is "the reasoner" made
# explicit and inspectable.

infer: $(INFERRED_TTL)

$(INFERRED_TTL): $(GRAPH_TTL) queries/infer-locatedin.rq | $(BUILD)
	arq --data $(GRAPH_TTL) --query queries/infer-locatedin.rq > $(CLOSURE_TTL)
	riot --formatted=ttl $(GRAPH_TTL) $(CLOSURE_TTL) > $@

# --- Layer 6: load both graphs into Fuseki ---
#   /training           — asserted only (query with geo:isLocatedIn+)
#   /training-inferred  — asserted + materialised closure (plain geo:isLocatedIn works)

load: $(GRAPH_TTL) $(INFERRED_TTL)
	curl -X POST -H "Content-Type: text/turtle" --data-binary "@$(GRAPH_TTL)" \
	     "$(FUSEKI_URL)/training/data?default"
	curl -X POST -H "Content-Type: text/turtle" --data-binary "@$(INFERRED_TTL)" \
	     "$(FUSEKI_URL)/training-inferred/data?default"
	@echo
	@echo "Loaded /training (asserted) and /training-inferred (+ closure)."
	@echo "Fuseki UI: forwarded port 3030. Then: make reveal"

# --- The reasoning reveal: same plain query, with vs without the closure ---

reveal: load
	@echo "== Plain geo:isLocatedIn — WITHOUT reasoning (/training): expect nothing =="
	@curl -s -H "Accept: text/csv" \
	      --data-urlencode "query@queries/people-born-in-europe-plain.rq" \
	      "$(FUSEKI_URL)/training/sparql"
	@echo
	@echo "== Plain geo:isLocatedIn — WITH the materialised closure (/training-inferred) =="
	@curl -s -H "Accept: text/csv" \
	      --data-urlencode "query@queries/people-born-in-europe-plain.rq" \
	      "$(FUSEKI_URL)/training-inferred/sparql"
	@echo
	@echo "Same query. The closure is the difference — that's what a reasoner buys you."

# --- A mapping cookbook: the same people.csv → the same triples, several ways ---
#
# Not "the" way to map — a palette. Each recipe is standalone; reach for the one
# that fits your context. `make cookbook` proves they all emit identical triples
# (canonical sorted N-Triples — our data has no blank nodes, so this is exact).

people-tarql: $(BUILD)/people-tarql.ttl    ## SPARQL CONSTRUCT over CSV
$(BUILD)/people-tarql.ttl: mappings/people.rq csv/people.csv | $(BUILD)
	tarql mappings/people.rq csv/people.csv > $@

people-rdflib: $(BUILD)/people-rdflib.ttl  ## plain Python, when code is what you have
$(BUILD)/people-rdflib.ttl: mappings/people_rdflib.py csv/people.csv | $(BUILD)
	python3 mappings/people_rdflib.py csv/people.csv > $@

# RML / YARRRML via rmlmapper (declarative, tool-independent, multi-source).
# Java is already in the image (Jena); we lazy-fetch the fat jar on first use so
# it doesn't bloat the base image — only pulled if you actually run this recipe.
RMLMAPPER_URL := https://github.com/RMLio/rmlmapper-java/releases/download/v8.1.0/rmlmapper-8.1.0-r380-all.jar
RMLMAPPER     := $(BUILD)/rmlmapper.jar

$(RMLMAPPER): | $(BUILD)
	@echo "Fetching rmlmapper (once, ~190MB)…"
	curl -fsSL "$(RMLMAPPER_URL)" -o $@

people-rml: $(BUILD)/people-rml.ttl  ## RML/YARRRML — declarative; watch the %20 pain
$(BUILD)/people-rml.ttl: mappings/people.rml.ttl csv/people.csv $(RMLMAPPER) | $(BUILD)
	java -jar $(RMLMAPPER) -m mappings/people.rml.ttl -s turtle -o $@

# Canonical form for comparison: sorted N-Triples.
$(BUILD)/%.nt: $(BUILD)/%.ttl
	riot --output=nt $< | LC_ALL=C sort > $@

COOKBOOK_NT := $(BUILD)/people-tarql.nt $(BUILD)/people-rdflib.nt $(BUILD)/people-rml.nt

cookbook: $(COOKBOOK_NT)
	@echo "Comparing every recipe against TARQL (canonical sorted N-Triples)…"
	@for r in $(filter-out %people-tarql.nt,$(COOKBOOK_NT)); do \
	  if diff -q $(BUILD)/people-tarql.nt $$r >/dev/null; then \
	    echo "  same as TARQL : $$r"; \
	  else echo "  DIFFERS       : $$r"; diff $(BUILD)/people-tarql.nt $$r | sed 's/^/        /'; fi; \
	done
	@echo
	@echo "Differences are the lesson, not a failure. RML percent-encodes 'New York'"
	@echo "(no string-replace without an FNML function), where TARQL, rdflib and R2RML"
	@echo "slug it. Same job, different tools, different pains. Pick what fits."

clean:
	rm -rf $(BUILD)
