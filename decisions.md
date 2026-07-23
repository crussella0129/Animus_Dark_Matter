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
- **Status:** Accepted (sprint 0); **amended by ADR-0006/0008 (sprint 1)** — the "harness" is the ICM *runtime* (Ferric's `ferric-guard` + constrained loop), not a component DM builds.
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
- **Status:** Accepted (sprint 0); **amended by ADR-0006/0008 (sprint 1)** — DM's Rust build is now the **knowledge server + `mirror` ingestion** only (the runtime is Ferric's); target language still Rust.
- **Context:** The framework needs a low-overhead stdio MCP server + enforcement
  harness. Default language preference is Rust; viable Rust MCP paths exist.
- **Decision:** Target **Rust** for the stdio MCP server, the `mirror` ingestion
  pipeline, and the harness. Fall back to Python only if a Rust MCP path proves
  unviable during s1.
- **Consequences:** Single low-overhead native binary aligns with the "near-zero
  overhead" goal. No runtime code is written in s0; this decision constrains s1.
- **SPEC:** §6, §10

## ADR-0006: Dark Matter is the knowledge layer; it rides Ferric's runtime
- **Status:** Accepted (sprint 1)
- **Context:** A review of `Animus_Ferric` (s1 research) found it **already
  implements** the ICM (`ferric-icm`), the constrained loop (`ferric-loop`), the
  external enforcement (`ferric-guard`), the OpenAI valve (`ferric server`), and an
  MCP server (`ferric mcp`) — working with small local models. The only thing it
  lacks is DM's on-demand, cached, MCP-served L3 knowledge layer.
- **Decision:** DM builds **only the knowledge layer + `mirror` ingestion** (SPEC
  §6). It does **not** build a runtime; it rides Ferric (or any conforming ICM
  agent). SPEC §3–§5/§7 become the formal spec that runtime conforms to.
- **Consequences:** No duplication of Ferric's mature runtime; DM stays a small
  repo. Supersedes the s0 assumption (ADR-0003/0005) that DM builds a harness.
- **SPEC:** §11 (and reframed §3–§5, §7); `INTEGRATION.md`

## ADR-0007: Integration seam is a Ferric built-in `fetch_reference` tool + a standalone MCP server
- **Status:** Accepted (sprint 1)
- **Context:** Ferric is an MCP *server* but has **no MCP-client** capability, so
  it cannot consume an external MCP server today. Its tools are built-in and the
  constrained action loop already carries `{thought, tool, args}` calls.
- **Decision:** Integrate via **two surfaces over one store**: (1) a Ferric
  **built-in `fetch_reference` tool** (cheapest seam — no new protocol; it rides
  the existing action ring) and (2) a **standalone MCP server** (`ref://`
  Resources + `fetch_isolated_context`) for any MCP-client agent. The constrained
  **JSONL engine stays in Ferric** — it is mature and works; the part that
  modularizes is the **L3 reference layer**, not the engine.
- **Consequences:** DM serves both Ferric and non-Ferric agents from one store.
  `ferric-icm::compose_stage` stops pre-folding `references/` and fetches on
  demand. Redirects the user's "modularize the JSONL engine" hypothesis.
- **SPEC:** §6, §11; `INTEGRATION.md`

## ADR-0008: Re-scope — the spec formalizes Ferric; DM's build is the knowledge layer
- **Status:** Accepted (sprint 1)
- **Context:** The s0 spec positioned DM as a whole framework/runtime, which
  over-claims now that Ferric is the reference implementation.
- **Decision:** Re-scope `SPEC.md`: a Scope banner + §11 (Relationship to Ferric)
  + "enforced by the runtime" reframe markers on §3–§5/§7 + a §10 roadmap where s2
  = build the knowledge server and a coordinated Ferric sprint does the
  integration. §6 (MCP layer) and §9 (validation) survive intact as DM's core.
- **Consequences:** The formalization is not wasted — it becomes the shared spec.
  The repo no longer over-claims; the build surface is small and correct.
- **SPEC:** banner, §10, §11; supersedes the framing of ADR-0003/0005
