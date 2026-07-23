# Architectural Decisions

Architectural Decision Records (ADRs) for Animus Dark Matter. Each records a
decision, its rationale, and the SPEC section it governs. Long-term memory —
tracked in git, persistent across sprints.

## ADR-0001: Dark Matter is an adaptation of ICM/MWP, credited explicitly
- **Status:** Accepted (sprint 0)
- **Context:** The README presented the five-layer design as original, but it is
  closely derived from the Model Workspace Protocol in *Interpretable Context
  Methodology* (arXiv:2603.16021, Van Clief & McDermott).
- **Decision:** Treat DM as an explicit adaptation of ICM/MWP. Credit the source
  and delineate DM's delta rather than reframing prior work as original.
- **Consequences:** A standalone `PROVENANCE.md` records inheritance + a delta
  table; SPEC §1 summarizes it. Integrity preserved; DM's real contribution is
  scoped to the deltas.
- **SPEC:** §1; `PROVENANCE.md`

## ADR-0002: L3 knowledge layer = MCP Resources for chunks + one Tool for search
- **Status:** Accepted (sprint 0)
- **Context:** The README specified the knowledge layer as a single Tool
  (`fetch_isolated_context`). Under the current MCP spec, read-only reference
  data is idiomatically a **Resource**, and Resources carry `ttlMs`/`cacheScope`
  caching.
- **Decision:** Model known reference chunks as **Resources** (`ref://` URIs,
  cached); keep **exactly one Tool**, `fetch_isolated_context`, for search/routing
  when the chunk URI is unknown.
- **Consequences:** Repeat reads hit cache (near-zero marginal context tokens);
  the "pristine context" claim becomes real. Slightly more surface than a single
  Tool, but idiomatic and cacheable.
- **SPEC:** §6

## ADR-0003: Isolation is enforced by an external harness, not model discipline
- **Status:** Accepted (sprint 0)
- **Context:** The README asks the model to "only read/write its layer." A 7–8B
  local model cannot be trusted to self-enforce; prompt-only isolation is not
  isolation.
- **Decision:** Move enforcement **out of the model** into a harness that
  executes the FSM, assembles `C_active`, and exposes a three-action alphabet
  (`WRITE→L4`, `FETCH→L3`, `STAGE_COMPLETE`), validating every action against the
  invariants. Withheld capabilities have no corresponding verb.
- **Consequences:** Isolation correctness is decoupled from model capability — a
  weaker model is less capable, never less safe. The harness + MCP server are the
  trusted computing base. Enables targeting small models at all.
- **SPEC:** §7 (see also §3, §5)

## ADR-0004: The ICM is formalized as FSM-over-stages × capability-lattice-over-layers
- **Status:** Accepted (sprint 0)
- **Context:** The source paper "lacks rigorous state-machine notation," and so
  did the README. Formalization needs a precise model with two orthogonal axes:
  *where we are* (stages) and *what we may touch* (layers).
- **Decision:** Model the framework as a **finite state machine** over stages
  (+ meta-states IDENTITY/ROUTING/DONE, guarded transitions, context-flush)
  crossed with a **capability lattice** `(2^{READ,FETCH,WRITE}, ⊆)` over layers,
  constrained by six checkable invariants.
- **Consequences:** The framework is now checkable (`verify-spec.sh`, and a
  future runtime harness) and communicable. Alternatives (pushdown automaton for
  nested stages) deferred until nesting is actually needed.
- **SPEC:** §3, §4, §5

## ADR-0005: Reference runtime is a Rust stdio MCP server; Python only if unviable
- **Status:** Accepted (sprint 0) — implementation deferred to s1
- **Context:** The framework needs a low-overhead stdio MCP server + enforcement
  harness. Default language preference is Rust; viable Rust MCP paths exist.
- **Decision:** Target **Rust** for the stdio MCP server, the `mirror` ingestion
  pipeline, and the harness. Fall back to Python only if a Rust MCP path proves
  unviable during s1.
- **Consequences:** Single low-overhead native binary aligns with the "near-zero
  overhead" goal. No runtime code is written in s0; this decision constrains s1.
- **SPEC:** §6, §10
