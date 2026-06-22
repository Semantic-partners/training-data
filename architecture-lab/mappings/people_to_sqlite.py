#!/usr/bin/env python3
"""Cookbook helper — load people.csv into a SQLite table.

R2RML maps *relational* sources, not files, so the R2RML recipe needs a database.
SQLite is the lightest real one, and Python's stdlib `sqlite3` is already in the
image — nothing to install. (INTEGER affinity turns the birth_year strings into
ints on insert, so the R2RML datatype lines up with the other recipes.)
"""
import csv
import sqlite3
import sys

src = sys.argv[1] if len(sys.argv) > 1 else "csv/people.csv"
db  = sys.argv[2] if len(sys.argv) > 2 else "build/people.db"

con = sqlite3.connect(db)
con.execute("DROP TABLE IF EXISTS people")
con.execute("CREATE TABLE people (id TEXT, name TEXT, birth_year INTEGER, birth_town TEXT)")
with open(src, newline="") as f:
    con.executemany(
        "INSERT INTO people VALUES (:id, :name, :birth_year, :birth_town)",
        list(csv.DictReader(f)),
    )
con.commit()
con.close()
print(f"loaded {src} -> {db}")
