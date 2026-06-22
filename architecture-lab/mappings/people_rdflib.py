#!/usr/bin/env python3
"""Cookbook recipe — people.csv → RDF with rdflib (plain Python).

Produces the *same triples* as mappings/people.rq (TARQL). The point of this
recipe: a "mapping" can just be code — read rows, mint IRIs, add triples — when
code is what you have and the shape is simple. No mapping language, no engine.

Run from the architecture-lab/ dir:  python3 mappings/people_rdflib.py > build/people-rdflib.ttl
"""
import csv
import sys
from rdflib import Graph, Namespace, Literal, RDF, RDFS
from rdflib.namespace import XSD

FAMILY = Namespace("http://family.org/")
BIO    = Namespace("http://example.org/bio/")
PERSON = Namespace("http://example.org/person/")
PLACE  = Namespace("http://example.org/place/")

CSV = sys.argv[1] if len(sys.argv) > 1 else "csv/people.csv"


def town_iri(name: str):
    # Same IRI the other recipes mint: spaces → underscores under .../place/.
    return PLACE[name.replace(" ", "_")]


def main() -> None:
    g = Graph()
    g.bind("family", FAMILY)
    g.bind("bio", BIO)
    with open(CSV, newline="") as f:
        for row in csv.DictReader(f):
            person = PERSON[row["id"]]
            g.add((person, RDF.type, FAMILY.Person))
            g.add((person, RDFS.label, Literal(row["name"])))
            g.add((person, BIO.birthYear,
                   Literal(int(row["birth_year"]), datatype=XSD.integer)))
            g.add((person, BIO.wasBornIn, town_iri(row["birth_town"])))
    g.serialize(destination=sys.stdout.buffer, format="turtle")


if __name__ == "__main__":
    main()
