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
#   make query     — list people born in Europe
#   make places    — list places by continent
#   make load      — load build/graph.ttl into the local GraphDB `training` repo
#   make clean     — wipe build/

BUILD := build
GRAPHDB_URL ?= http://graphdb:7200
REPO ?= training

PEOPLE_TTL  := $(BUILD)/people.ttl
PLACES_TTL  := $(BUILD)/places.ttl
GRAPH_TTL   := $(BUILD)/graph.ttl
REPORT_TTL  := $(BUILD)/shacl-report.ttl

.PHONY: all validate query places load clean

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

# --- Layer 5: load into GraphDB so the reasoner can do its job ---

load: $(GRAPH_TTL)
	curl -X POST \
	     -H "Content-Type: text/turtle" \
	     --data-binary "@$(GRAPH_TTL)" \
	     "$(GRAPHDB_URL)/repositories/$(REPO)/statements"
	@echo
	@echo "Loaded into $(GRAPHDB_URL)/repositories/$(REPO)"
	@echo "Try the workbench (forwarded port 7200) — and toggle 'Include inferred' on/off."

clean:
	rm -rf $(BUILD)
