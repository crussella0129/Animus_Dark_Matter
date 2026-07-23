# Animus Dark Matter

### The MCP knowledge layer for ICM agents — Ferric-native and standalone

Dark Matter is the **knowledge layer** that lets a small local model
(e.g. Llama-3-8B, Qwen-2.5-7B) reason above its weight class: it serves domain
knowledge from a stdio **MCP** vault so only the *exact chunk* a step needs enters
context, keeping the window pristine. It plugs into an **ICM runtime** — the
*Interpretable Context Methodology* filesystem state machine, implemented by
[Animus Ferric](https://github.com/crussella0129/Animus_Ferric) — or serves any
MCP-client agent standalone. DM builds the knowledge layer; the runtime is
Ferric's (see [`SPEC.md` §11](./SPEC.md) and [`INTEGRATION.md`](./INTEGRATION.md)).

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

- **The ICM runtime (Ferric).** A folder hierarchy is a state machine: the model
  advances through isolated stages — one job each — with context **flushed on
  every transition** (except pinned identity). Enforcement is external: the model
  is reduced to a few actions and *physically cannot* escape its layer (Ferric's
  `ferric-guard` + constrained loop). DM does **not** build this — it formalizes
  it (SPEC §3–§5, §7) and rides it.
- **The knowledge layer (Dark Matter's build).** Documentation is mirrored as
  clean, chunked markdown and served over MCP — reference chunks as cacheable
  **Resources** plus one `fetch_isolated_context` / `fetch_reference` tool. Only
  the exact chunk a step needs ever enters context: near-zero token bloat. It
  replaces the runtime's habit of folding whole reference files into the prompt.
- **Two surfaces, one store.** The same vault is a **Ferric built-in tool**
  (bolt-on) *and* a **standalone MCP server** (any MCP-client agent) — see
  [`INTEGRATION.md`](./INTEGRATION.md).

## Status

| Phase | Deliverable | State |
|-------|-------------|-------|
| **s0** | Formal specification, provenance, ADRs, scaffold, verifier | ✅ done |
| **s1** | Re-scope: DM = the knowledge layer for ICM agents; `INTEGRATION.md`; ADRs | ✅ design settled |
| **s2** | Rust stdio **MCP knowledge server** + `mirror` ingestion (DM's only runtime deliverable) | ⏳ planned |
| Ferric | `fetch_reference` tool + `compose_stage` change (in `Animus_Ferric`) | ⏳ planned |

The runtime (ICM state machine, enforcement, constrained loop) is **Ferric's**; DM
builds the knowledge layer on top. Not yet a runnable system.

## Documents

- **[`SPEC.md`](./SPEC.md)** — the formal specification: the FSM × capability
  lattice, the six invariants, the MCP contract, the enforcement model, a
  falsifiable validation design, and §11 (relationship to Ferric).
- **[`INTEGRATION.md`](./INTEGRATION.md)** — how the knowledge layer plugs into
  Ferric (the `fetch_reference` tool) and serves any MCP client standalone.
- **[`PROVENANCE.md`](./PROVENANCE.md)** — credits and attribution.
- **[`template/MANIFEST.md`](./template/MANIFEST.md)** — an instantiable workspace
  scaffold (the five layers, with a worked example).
- **[`decisions.md`](./decisions.md)** — architectural decision records.

## Provenance

Dark Matter is an **adaptation** of the Interpretable Context Methodology / Model
Workspace Protocol (Van Clief & McDermott, [arXiv:2603.16021](https://arxiv.org/abs/2603.16021))
and Anthropic's Model Context Protocol. The same ICM paper is independently
implemented by Ferric's `ferric-icm`; DM **rides that runtime** and its own
contribution narrows to the **MCP-served knowledge layer** (§6). See
[`PROVENANCE.md`](./PROVENANCE.md).

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
