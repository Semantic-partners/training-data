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

.PHONY: all validate query places infer load reveal clean

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

# --- Layer 6: load the graphs into Fuseki (one per reasoning recipe) ---
#   /training           — asserted only (query with geo:isLocatedIn+)
#   /training-inferred  — asserted + materialised closure (plain geo:isLocatedIn works)
#   /training-reasoned  — asserted only; the live reasoner derives the closure itself

load: $(GRAPH_TTL) $(INFERRED_TTL)
	curl -X POST -H "Content-Type: text/turtle" --data-binary "@$(GRAPH_TTL)" \
	     "$(FUSEKI_URL)/training/data?default"
	curl -X POST -H "Content-Type: text/turtle" --data-binary "@$(INFERRED_TTL)" \
	     "$(FUSEKI_URL)/training-inferred/data?default"
	curl -X POST -H "Content-Type: text/turtle" --data-binary "@$(GRAPH_TTL)" \
	     "$(FUSEKI_URL)/training-reasoned/data?default"
	@echo
	@echo "Loaded /training (asserted), /training-inferred (+ materialised closure),"
	@echo "and /training-reasoned (asserted — the live reasoner infers the rest)."
	@echo "Fuseki UI: forwarded port 3030. Then: make reveal"

# --- The reasoning reveal: same plain query, three recipes ---
# The arc: no reasoning -> you materialise the closure by hand -> the engine does
# it for you. Same question, same answer, three honest mechanisms.

reveal: load
	@echo "== Plain geo:isLocatedIn — WITHOUT reasoning (/training): expect nothing =="
	@curl -s -H "Accept: text/csv" \
	      --data-urlencode "query@queries/people-born-in-europe-plain.rq" \
	      "$(FUSEKI_URL)/training/sparql"
	@echo
	@echo "== WITH the closure you MATERIALISED by hand (/training-inferred) — make infer =="
	@curl -s -H "Accept: text/csv" \
	      --data-urlencode "query@queries/people-born-in-europe-plain.rq" \
	      "$(FUSEKI_URL)/training-inferred/sparql"
	@echo
	@echo "== ...and now the engine does it for you — a LIVE reasoner (/training-reasoned) =="
	@curl -s -H "Accept: text/csv" \
	      --data-urlencode "query@queries/people-born-in-europe-plain.rq" \
	      "$(FUSEKI_URL)/training-reasoned/sparql"
	@echo
	@echo "Same query, same answer, three ways: the query (property path), you"
	@echo "(materialised), or the engine (live reasoner). That's what a reasoner buys you."

clean:
	rm -rf $(BUILD)
