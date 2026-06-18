# Spike: live reasoner in Fuseki (vs offline materialised closure)

**Question:** can Fuseki do the reasoning *live* — derive the transitive closure
of `geo:isLocatedIn` itself — instead of us materialising it offline with
`make infer`? Earlier OWLMicro/OWLFB attempts didn't infer over data loaded after
startup, which is why the lab settled on offline materialisation.

**Answer: yes**, with a `GenericRuleReasoner` + an explicit rule. Verified on the
pinned `stain/jena-fuseki:5.1.0` with the repo's mount setup:

- `config-inference.ttl` makes `/training-inferred` a live `ja:InfModel`
  (GenericRuleReasoner, `rules.txt`) over a plain base model.
- POST data via GSP (`/training-inferred/data?default` — the exact `make load`
  path) → **the reasoner reflects it and infers**: the plain (no `+`)
  Europe query returns the person, and the derived `london → europe`
  `geo:isLocatedIn` triple is present (count 3 = 2 asserted + 1 inferred).

So the OWL-reasoner quirk, not "Fuseki can't infer over GSP data", was the wall.
An explicit rule is also *more teachable* than `owl:TransitiveProperty` — the
inference is right there, not hidden behind OWL semantics.

## Why this is teaching gold: one answer, three mechanisms

The lab now demonstrates the **same transitive closure three ways**, with honest
trade-offs — a genuinely strong reasoning module:

| Mechanism | How | Trade-off |
|---|---|---|
| **Property path** | `geo:isLocatedIn+` on plain `/training` | no reasoner; the *query* does the work, every time |
| **Offline materialised** | `make infer` (arq CONSTRUCT) → load `/training-inferred` | closure is an explicit file you can open + read; extra build step |
| **Live reasoner** | this config; reasoner derives on load | no build step; closure is implicit (less tangible to show) |

## How to try it

Point the Fuseki service at this config instead of the default `config.ttl` —
in `docker-compose.yml`, mount `config-inference.ttl` to `/fuseki/config.ttl`
and add `./fuseki/rules.txt:/fuseki/rules.txt:ro`. Then `make load` (no
`make infer` needed) and run the plain query against `/training-inferred`.

## Recommendation (delivery is days away)

**Do not swap the default for this run.** The offline materialised reveal is
already wired into the slides, README, and `make reveal`, and it's verified.
Keep it as the shipping default. Adopt/raise the live-reasoner as either:

- a **capstone aside** in the reasoning module ("…and you can have Fuseki do this
  for you automatically — here's the rule"), or
- the **default after the course**, simplifying the pipeline (drop `make infer`;
  `/training-inferred` just reasons).

This spike proves the option is real and reliable; the call on when to fold it in
is yours.
