# L1 — Routing Matrix

The routing matrix maps a **problem signature** to an **ordered stage sequence**
and, per stage, the **L3 reference bindings** that stage is allowed to fetch. The
harness reads this in the `ROUTING` state (SPEC §4) to plan the run.

**Determinism (INV-6):** routing is a pure function. For a fixed matrix and a
fixed problem signature it MUST resolve the same sequence and bindings every
time. Keep matches unambiguous and ordered (first match wins).

## Format

Each route is one entry:

```yaml
- signature: <stable id or match pattern for a class of tasks>
  match:     <keywords / regex the harness uses to classify the task>
  stages:    [<ordered stage folder names under 02_stages/>]
  bindings:                       # which L3 targets each stage may fetch
    <stage-folder>: [<ref-target>, ...]
```

- `stages` are folder names in `02_stages/`, executed in list order.
- `bindings[stage]` lists the `ref://<target>` corpora that stage may fetch
  (SPEC §6). A stage can fetch **only** its bound targets; anything else is
  refused by the knowledge server.

## Worked example

```yaml
routes:
  - signature: code-task/implement-against-library
    match: ["implement", "function", "using <library>", "against the API"]
    stages: [00_example_stage]        # a real workspace adds 01_verify, 02_document, …
    bindings:
      00_example_stage: [stdlib-docs] # may fetch ref://stdlib-docs/… only

  - signature: default
    match: ["*"]                      # fallback; first match wins, so keep this last
    stages: [00_example_stage]
    bindings:
      00_example_stage: []            # no reference access for the fallback route
```

Here a task classified as `implement-against-library` runs the single stage
`00_example_stage`, which is permitted to fetch reference chunks from the
`stdlib-docs` corpus and nothing else. Add stages by creating numbered folders in
`02_stages/` and listing them (with their own bindings) in a route.
