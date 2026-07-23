# Animus Dark Matter

### Local Intelligence Multiplier (LIM) — folder-structure agent architecture for small local models

Dark Matter turns a static local directory tree into a physical **state machine**
(the *Interpretable Context Methodology*, ICM) and serves domain knowledge from a
stdio **MCP** vault. By keeping knowledge retrieval and state-tracking *out* of a
model's weights and *out* of its active context window, it lets a small local
model (e.g. Llama-3-8B, Qwen-2.5-7B) reason well above its weight class.

```text
[ LOCAL MODEL CONTEXT BOUNDARY ]
 ├── Layer 0: System Identity        (pinned execution constraints)
 ├── Layer 1: Context Routing Matrix (maps problems → stages + data targets)
 ├── Layer 2: Isolated Stages        (one directory per state; one stage, one job)
 ├── Layer 3: Hard-Gated Reference   (MCP knowledge vault — served, never read directly)
 └── Layer 4: Stateful Artifacts     (the only writable layer; shared scratchpad)
```

## Why "Dark Matter"

The name *is* the thesis. In cosmology, galaxies rotate faster than their
**visible** mass can explain — the discrepancy implies a vast reservoir of unseen
mass whose gravity shapes everything you *can* see.

- **Visible matter** = the model's weights + whatever is in its active context
  window right now — everything "lit up" in a single inference.
- **Dark matter** = the filesystem structure + the MCP vault — the overwhelming
  majority of the system's effective information and control, never fully lit in
  any one inference, yet shaping the model's whole trajectory (the harness is
  "gravity").

A small model that performs far better than its **parametric** mass predicts is
exhibiting the same anomaly: unseen **structural** mass is doing the work. That
flattening of the capability-versus-parameters curve is the **multiplier**. (Full
treatment in [`SPEC.md` §0.4](./SPEC.md).)

## How it works

- **The ICM engine (state machine).** The folder hierarchy enforces operational
  isolation. The model cannot fuse intent-parsing, doc-fetching, and code
  generation into one overloaded prompt; it advances through discrete stages,
  and context is **flushed on every transition** (except the pinned identity),
  keeping the window pristine.
- **The MCP layer (knowledge vault).** Documentation is mirrored as clean,
  chunked markdown and exposed over a stdio MCP server — reference chunks as
  cacheable **Resources**, plus one `fetch_isolated_context` search Tool. Only
  the exact chunk a step needs ever enters context: near-zero token bloat.
- **External enforcement.** Isolation is enforced by a **harness**, not by asking
  the model to behave. The model is reduced to three actions
  (`write→L4`, `fetch→L3`, `stage-complete`); anything else has no verb to
  invoke. Isolation correctness is therefore **decoupled from model capability**
  — a weaker model is less capable, never less safe.

## Status

| Phase | Deliverable | State |
|-------|-------------|-------|
| **s0** | Formal specification, provenance, ADRs, scaffold, verifier | ✅ this repo |
| **s1** | Rust stdio MCP server + `mirror` ingestion + enforcement harness | ⏳ planned |
| **s2** | Multiplier validation benchmark on a real local model | ⏳ planned |

The framework is currently a **formalized design**, not yet a runnable system.

## Documents

- **[`SPEC.md`](./SPEC.md)** — the formal specification: the FSM × capability
  lattice, the six invariants, the MCP contract, the enforcement model, and a
  falsifiable validation design.
- **[`PROVENANCE.md`](./PROVENANCE.md)** — credits and attribution.
- **[`template/MANIFEST.md`](./template/MANIFEST.md)** — an instantiable workspace
  scaffold (the five layers, with a worked example).
- **[`decisions.md`](./decisions.md)** — architectural decision records.

## Provenance

Dark Matter is an **adaptation** of the Interpretable Context Methodology / Model
Workspace Protocol (Van Clief & McDermott, [arXiv:2603.16021](https://arxiv.org/abs/2603.16021))
and Anthropic's Model Context Protocol. Its own contributions are the small-local
re-targeting, the formalization, the MCP hard gate, the external enforcement
model, and the validation design. See [`PROVENANCE.md`](./PROVENANCE.md).

---

### The Master Framework Prompt (informal bootstrap)

> This is the informal seed prompt. The **normative** contract is
> [`SPEC.md`](./SPEC.md); where they differ, the spec wins.

```markdown
Initialize a local AI architecture implementing the Local Intelligence Multiplier
(LIM) framework: an stdio Model Context Protocol (MCP) server plus an
Interpretable Context Methodology (ICM) filesystem state machine, driven by an
enforcement harness. Establish the 5-layer hierarchy: `00_identity/` (pinned
constraints), `01_routing/` (problem → stage-sequence + reference bindings),
`02_stages/` (isolated sequential stages, "one stage, one job", with
Inputs·Process·Outputs contracts), `03_reference/` (clean-markdown knowledge,
served ONLY via MCP), and `04_artifacts/` (the only writable layer). Enforce the
layering in the harness, not by trusting the model: expose exactly three actions
(write→L4, fetch→L3 via MCP, stage-complete), flush context on every stage
transition, and serve reference chunks as cached MCP Resources plus one
`fetch_isolated_context` search Tool, keeping the context window text-only and
free from parametric saturation.
```
