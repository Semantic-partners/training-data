# Client-side validation when the triple store has no server-side SHACL

If your triple store supports *server-side* SHACL validation, then it will reject
any non-comformant update to the data.

Suppose you have loaded SHACL shapes declaring `onto:myProperty` being functional:


```turtle
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix onto: <http://example.org/onto#> .
@prefix ex: <http://example.org/> .

ex:MyShape
    a sh:NodeShape ;
    sh:targetClass onto:MyClass ;
    sh:property [
        sh:path onto:myProperty ;
        sh:minCount 1 ;
        sh:maxCount 1
    ] .
```

and data:
```
:mySubject onto:myProperty :myObject1.
```

then inserting:
```
INSERT DATA {
    :mySubject onto:myProperty :myObject2.
}
```
will fail with a message about the violation.

But, if your triple store of choice does *not* support server-side SHACL, you can still
validate data *client-side*, either to check its conformity or to test what would happe if you did update the graph.

Related image: [image.png](image.png)

## Mode 1: Fetch relevant data, then run SHACL locally

Workflow:
1. Query and extract the specific RDF subgraph you care about (use a CONSTRUCT)
2. Load that data into a graph and apply a SHACL shape(s) on it

When this is good:
- Scoped checks on a specific object or or sub-graph
- Example: validating one specific BOM and its related nodes

Main limitation:
- This approach is only practical for one small dataset at a time
(must fit into memory)


## Mode 2: query for violations with SPARQL

Workflow:
1. Encode each constraint as a SPARQL query that returns violating resources (with a SELECT)
2. Run the query(es) against the triple store (or a graph)
3. Treat non-empty result sets as validation failures

When this is good:
- Global validations across the entire graph
- Example: property `onto:myProperty` must never have two different objects for the same subject

Main advantage:
- Works well for global checks, involving the whole dataset
- it doesn't need any in-memory processing

## Practical rule of thumb

- Use Mode 1 for targeted, case-level validation (small scope, such as one BOM);
- Use Mode 2 for global integrity rules that must hold everywhere in the store - global invariants
