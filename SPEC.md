# Animus Dark Matter — Local Intelligence Multiplier (LIM): Formal Specification

**Status:** Draft v0 (sprint s0 — formalization). Runtime implementation is
scheduled for s1; empirical validation for s2. This document is normative for
the framework's *design*; §10 tracks what is deferred.

**Contents**

- [0. Abstract & the Dark Matter Thesis](#0-abstract--the-dark-matter-thesis)
- [1. Provenance (summary)](#1-provenance-summary)
- [2. Definitions, Notation & Glossary](#2-definitions-notation--glossary)
- [3. The Layer Model — a Capability Lattice](#3-the-layer-model--a-capability-lattice)
- [4. The ICM State Machine](#4-the-icm-state-machine)
- [5. Invariants](#5-invariants)
- [6. The MCP Knowledge Layer](#6-the-mcp-knowledge-layer)
- [7. The Enforcement Model](#7-the-enforcement-model)
- [8. Canonical Directory Layout](#8-canonical-directory-layout)
- [9. Validation Design — Measuring the Multiplier](#9-validation-design--measuring-the-multiplier)
- [10. Roadmap & Open Questions](#10-roadmap--open-questions)

---

## 0. Abstract & the Dark Matter Thesis

### 0.1 What this is

**Animus Dark Matter** is a framework for making a *small, local* language model
reason far above its weight class by moving two burdens — **domain-knowledge
recall** and **multi-step state-tracking** — out of the model's parameters and
out of its active context window, and into an external structure the model never
holds in full at any one moment:

- a **filesystem state machine** (the *Interpretable Context Methodology*, ICM)
  that physically partitions the workflow into isolated stages, and
- an **MCP knowledge vault** (a stdio *Model Context Protocol* server) that
  serves clean, text-only reference chunks on demand.

The framework's promised effect is the **Local Intelligence Multiplier (LIM)**:
structure multiplies effective capability.

### 0.2 The thesis, stated precisely

Let `cap_T(M, S)` denote the capability (e.g. task success rate) of a model `M`
on a task class `T` when supported by an external structure `S`, with `S = ∅`
meaning the model works alone. Let `M_small` be a 7–8B local model, `M_frontier`
a large hosted model, and `S_DM` the Dark Matter structure. Let `T*` be the
framework's **target task class**: knowledge-intensive, multi-step tasks in which
retrieval and state-tracking — not raw parametric cleverness — dominate the
difficulty (e.g. "implement feature X against library Y's current API," carried
across research → plan → code → verify).

> **Thesis (LIM).** On `T*`,
>
> &nbsp;&nbsp;&nbsp;&nbsp;`cap_T*(M_small, S_DM)  ≫  cap_T*(M_small, ∅)`,
>
> and, more ambitiously,
>
> &nbsp;&nbsp;&nbsp;&nbsp;`cap_T*(M_small, S_DM)  →  cap_T*(M_frontier, ∅)`.
>
> That is: the structure closes most of the small-vs-frontier gap on `T*`.

Define the **multiplier**

&nbsp;&nbsp;&nbsp;&nbsp;`μ  :=  cap_T*(M_small, S_DM) / cap_T*(M_small, ∅)  >  1`&nbsp;&nbsp;(ideally `≫ 1`).

The thesis is an empirical claim, not an axiom. §9 specifies the experiment that
would confirm or **falsify** it; this document's job is to make the framework
precise enough for that experiment to be meaningful.

### 0.3 Mechanism

The multiplier is claimed to arise from a single lever — **keeping the active
context `C_active` minimal and pristine at every step** — applied structurally:

1. **Knowledge is offloaded** to L3 and delivered in small, exact chunks via MCP
   (§6), so `C_active` never carries a library's whole documentation, only the
   fragment the current step needs.
2. **State is offloaded** to the filesystem: the stage FSM (§4) tracks *where we
   are*, and L4 artifacts (§3) carry *what we have produced*, so the model need
   not hold the whole plan in context.
3. **Isolation** (one active stage; §4, §5) prevents the model from having to
   reconcile intent-parsing, doc-fetching, and code-generation in a single
   inference — the failure mode small models are worst at.

The model's scarce parametric and context budget is thus spent on **reasoning**,
not recall or bookkeeping. The framework's wager is that recall+bookkeeping is
most of what separates `M_small` from `M_frontier` on `T*`.

### 0.4 Why "Dark Matter" — the name is the thesis

In cosmology, galaxies rotate faster than their *visible* (luminous) mass can
explain; the discrepancy implies a large reservoir of **unseen mass** whose
gravity shapes the motion of everything visible. You never observe dark matter
directly — only its effect on the luminous matter's trajectory.

Map this onto the framework:

| Cosmology | Animus Dark Matter |
|---|---|
| Luminous (baryonic) matter | The model's weights **+** its active context window `C_active` — everything "lit up" in a single inference |
| Dark matter | The filesystem ICM **+** MCP vault — the overwhelming majority of the system's effective information/control "mass," never fully lit in any one inference |
| Gravity shaping visible motion | The **harness** (§7) gating what enters `C_active`, shaping the model's reasoning trajectory step by step |
| Rotation curve faster than luminous mass predicts | A small model performing on `T*` **better than its luminous (parametric) mass predicts** |

The rotation-curve anomaly is the whole point: capability-versus-parameter-count
is *flatter* than expected because unseen **structural mass** is doing the work.
That flattening is the **multiplier**. (The analogy is a naming intuition, not a
physical claim; §9 is where it earns its keep.)

---

## 1. Provenance (summary)

Dark Matter is an **adaptation**, and says so plainly. Its five-layer design is
closely derived from the **Model Workspace Protocol (MWP)** introduced in
*"Interpretable Context Methodology: Folder Structure as Agentic Architecture"*
(Van Clief & McDermott, arXiv:2603.16021). DM's layers L0–L4 map almost
one-to-one onto MWP's layers. Full credit, citations, and a departure table live
in [`PROVENANCE.md`](./PROVENANCE.md); the essentials:

**What DM inherits from ICM/MWP:** folder-structure-as-agent-architecture; the
five-layer identity/routing/stages/reference/artifacts split; numbered stage
folders; stage contracts expressed as Inputs·Process·Outputs; the principle that
the human-inspectable filesystem *is* the control surface.

**What DM changes (its reason to exist):**

1. **Target.** MWP was demonstrated on a frontier model (Claude Opus 4.6). DM
   re-targets **small local models** (Llama-3-8B, Qwen-2.5-7B) — the setting
   where structure must substitute for raw capability.
2. **A hard MCP knowledge gate.** MWP reads L3 reference files directly. DM makes
   L3 reachable **only** through a stdio MCP server (§6), which becomes the
   enforcement point for context isolation.
3. **A formal model.** The ICM paper explicitly *"lacks rigorous state-machine
   notation."* DM supplies it: an FSM over stages × a capability lattice over
   layers, with checkable invariants (§4, §5).
4. **External enforcement.** MWP relies on a capable model largely respecting the
   structure. DM assumes an *un*reliable small model and moves enforcement
   **out** of the model into a harness (§7).
5. **A falsifiable validation design** for the multiplier claim (§9).

---

## 2. Definitions, Notation & Glossary

### 2.1 Notation

| Symbol | Meaning |
|---|---|
| `M`, `M_small`, `M_frontier` | A model; a 7–8B local model; a large hosted model |
| `T`, `T*` | A task class; the framework's target task class (knowledge- and state-heavy, multi-step) |
| `S`, `S_DM`, `∅` | An external support structure; the Dark Matter structure; no structure (model alone) |
| `cap_T(M, S)` | Capability (e.g. success rate) of `M` on `T` under support `S` |
| `μ` | The multiplier, `cap_T*(M_small, S_DM) / cap_T*(M_small, ∅)` |
| `C_active` | The active context window presented to `M` at one inference step |
| `L0 … L4` | The five layers (§3) |
| `Σ`, `σ`, `δ`, `G` | ICM state set; a state; transition function; transition guards (§4) |
| `INV-k` | Invariant number `k` (§5) |

### 2.2 Glossary

- **LIM (Local Intelligence Multiplier).** The framework's goal and claimed
  effect: an external structure multiplies a small local model's effective
  capability on `T*`. The framework is sometimes referred to by this name.
- **ICM (Interpretable Context Methodology).** Folder-structure-as-agent-
  architecture. In DM, formalized as an FSM over **stages** × a **capability
  lattice** over **layers** (§4).
- **MWP (Model Workspace Protocol).** The concrete protocol from the ICM paper
  (arXiv:2603.16021) that DM adapts. See §1, `PROVENANCE.md`.
- **Layer (L0–L4).** A horizontal band of the structure with a fixed capability
  profile: L0 identity, L1 routing, L2 stages, L3 reference, L4 artifacts (§3).
- **Stage.** A unit of work living in L2. Exactly one stage is *active* at any
  time. The FSM's non-meta states are stages (§4).
- **Capability lattice.** The partial order over `{read, fetch, write}`
  capabilities across layers that constrains what the active state may touch
  (§3). The orthogonal axis to the stage FSM.
- **Hard gate.** An access boundary enforced **externally** (by the harness or
  the MCP server), not by model self-discipline. Specifically: L3 reference
  content is reachable *only* via MCP fetch (§6), never by direct read.
- **Parametric saturation.** Degradation of a model's reasoning when its weights
  and/or context are overloaded with recalled knowledge and bookkeeping. DM's
  design goal is to avoid it by offloading both (§0.3).
- **Multiplier (`μ`).** The capability ratio defined in §0.2 and §2.1.
- **Context minimality.** The property that `C_active` contains only what the
  active state needs: pinned L0 + the active stage contract + explicitly fetched
  L3 chunks + referenced L4 artifacts — nothing else (INV-5, §5).
- **Harness.** The external executor that drives `M`, runs the state machine,
  enforces the lattice and invariants, and mediates **all** of the model's I/O
  (§7). In the metaphor, the harness is "gravity."
- **Artifact.** A file written to L4 by a stage — the only runtime-writable
  state and the sole medium of inter-stage communication (§3, INV-4).
- **Routing matrix.** The L1 mapping from a problem signature to an ordered
  **stage sequence** plus, per stage, the L3 reference bindings that stage is
  allowed to fetch (§3, §6).
- **Stage contract.** The L2 `(Inputs, Process, Outputs)` specification of a
  stage. Its **Outputs** clause is the transition guard `G` for leaving that
  stage (§4).

---

## 3. The Layer Model — a Capability Lattice

_L0–L4 are defined here as a capability lattice: each layer carries a fixed
`read`/`write`/`MCP-fetch` profile, with L4 the only runtime-writable layer and
L3 reachable only by MCP fetch._

<!-- populated by T-002 -->

## 4. The ICM State Machine

_The ICM is formalized here as a finite state machine over stages (plus the meta
states IDENTITY, ROUTING, DONE), with a transition function δ, guards requiring
the source stage's Outputs contract to be satisfied, and context-flush-on-
transition. Includes a Mermaid state diagram._

<!-- populated by T-003 -->

## 5. Invariants

_Six checkable invariants (INV-1 … INV-6) that any conforming implementation
must uphold: single active stage, write-isolation to L4, the L3 MCP gate, stage
isolation, context minimality, and routing determinism._

<!-- populated by T-004 -->

## 6. The MCP Knowledge Layer

_The L3 knowledge vault is specified here against the current MCP protocol:
reference chunks as Resources (`ref://` URIs with `ttlMs`/`cacheScope`), a single
`fetch_isolated_context` Tool for search/routing, the server as sole L3
gatekeeper, and the (deferred) ingestion pipeline's input→output contract._

<!-- populated by T-005 -->

## 7. The Enforcement Model

_How the hard gate is actually enforced for an untrusted small model: the harness
executes the FSM, presents only the permitted context, constrains the model's
actions to {write→L4, fetch→L3, stage-complete}, and validates every action
against the invariants — "physically cannot," not "must not."_

<!-- populated by T-006 -->

## 8. Canonical Directory Layout

_The canonical on-disk layout (`00_identity/ … 04_artifacts/`) that the
`template/` scaffold instantiates._

<!-- populated by T-007 -->

## 9. Validation Design — Measuring the Multiplier

_A falsifiable experiment for the multiplier: experimental arms (M_small alone,
M_small+DM, M_frontier ceiling), metrics (success rate, tokens-in-context/step,
invariant-violation count), a task set over `T*`, and explicit pass/falsify
criteria._

<!-- populated by T-007 -->

## 10. Roadmap & Open Questions

_What is deferred and to which sprint (s1 runtime, s2 validation), plus the open
design questions this spec does not yet close._

<!-- populated by T-007 -->
