# Stage 00 — `example_stage` (Draft Implementation)

A worked example of an L2 **stage contract**. A stage does one job; its contract
is exactly three parts. The **Outputs** clause is the transition guard `G` (SPEC
§4.4): the harness lets the run leave this stage only when every listed output
exists in L4 and is well-formed.

## Inputs
What this stage is given (assembled into context by the harness — SPEC §7):

- **From L4 (prior artifacts):** `04_artifacts/task/spec.md` — the task
  statement (what to implement and its acceptance criteria). *(On the first
  stage of a run this is seeded by the caller.)*
- **From L3 (fetch on demand):** the `stdlib-docs` reference corpus this stage is
  bound to in `01_routing/ROUTING.md`. Fetch only the specific API chunk you
  need, via the knowledge server — do not pull whole documents.

## Process
1. Read the task spec from the input artifact.
2. Fetch the exact reference chunk(s) for the API you will call (one focused
   fetch per unknown, not a broad sweep).
3. Draft the implementation that satisfies the task's acceptance criteria using
   the *current* API as returned by the fetch (do not rely on memorized APIs).
4. Write the output artifact. Then emit `STAGE_COMPLETE`.

## Outputs
Written to this stage's output area under L4 (the only writable layer):

- **`04_artifacts/00_example_stage/output/implementation.md`** — the drafted
  implementation, with a short note of which `ref://stdlib-docs/…` chunks it
  relied on.

**Guard `G(00_example_stage)`** holds ⟺ `implementation.md` exists at that path
and is non-empty. Until then, `STAGE_COMPLETE` is refused and you remain in this
stage.
