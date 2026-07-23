# Provenance & Attribution

Animus Dark Matter is an **adaptation and formalization** of prior work, not an
original architecture. This document records what it borrows, from whom, and
exactly what it changes. The framework's contribution is the *combination* of
re-targeting, formalization, external enforcement, and a falsifiable validation
design — not the five-layer idea itself, which is inherited.

## Primary sources

1. **ICM / MWP — the architecture DM adapts.**
   Jake Van Clief & David McDermott, *"Interpretable Context Methodology: Folder
   Structure as Agentic Architecture,"* arXiv:**2603.16021**.
   <https://arxiv.org/abs/2603.16021> · reference implementation:
   *Interpretable-Context-Methodology (ICM)* by RinDig.
   Introduces the **Model Workspace Protocol (MWP)**: folder-structure-as-agent-
   architecture, a five-layer context hierarchy, numbered stage folders, and
   stage contracts expressed as Inputs · Process · Outputs. Demonstrated with a
   **frontier** model (Claude Opus 4.6).

2. **Model Context Protocol (MCP) — the knowledge-gate mechanism.**
   Anthropic, Model Context Protocol (spec revision 2026-07-28 RC).
   <https://modelcontextprotocol.io> · <https://blog.modelcontextprotocol.io>
   Supplies the stdio transport and the **Resource / Tool / Prompt** primitives
   (and `ttlMs` / `cacheScope` resource caching) that DM's L3 knowledge layer
   (SPEC §6) is built on.

## What Dark Matter inherits from ICM / MWP

- Folder-structure-as-agent-architecture: the filesystem *is* the control surface.
- The five-layer split — identity / routing / stages / reference / artifacts —
  which DM keeps as L0–L4 almost one-to-one.
- Numbered, ordered stage folders.
- Stage contracts as `Inputs · Process · Outputs`.
- The value of human-inspectable, plain-markdown state.

## What Dark Matter changes (its reason to exist)

| # | Departure | MWP (as published) | Animus Dark Matter | SPEC |
|---|-----------|--------------------|--------------------|------|
| 1 | **Target model** | Frontier (Claude Opus 4.6) | **Small local** models (Llama-3-8B, Qwen-2.5-7B) — the regime where structure must substitute for raw capability | §0, §9 |
| 2 | **Knowledge access** | L3 reference files read directly | L3 reachable **only** via a stdio **MCP hard gate** (Resources + one search Tool), with `ttlMs`/`cacheScope` caching | §6 |
| 3 | **Formal model** | Prose; *"lacks rigorous state-machine notation"* | An explicit **FSM over stages × capability-lattice over layers**, with a transition tuple and guards | §3, §4 |
| 4 | **Invariants** | Implicit conventions | Six **checkable invariants** (INV-1…6) with observer procedures | §5 |
| 5 | **Enforcement** | Relies on a capable, well-behaved model | **External harness** executes the FSM; the model is a 3-action constrained function — "physically cannot," not "must not" | §7 |
| 6 | **Validation** | Practitioner-survey findings (U-shaped editing) | A **falsifiable benchmark** for the multiplier (arms, metrics, pass/falsify criteria) | §9 |

Departures 1, 2, and 5 are the load-bearing ones: DM exists because a small local
model needs the knowledge gate (2) and the external enforcement (5) that a
frontier model in MWP did not.

## Positioning statement

Where this framework's design overlaps MWP, the credit is MWP's. Dark Matter's
own claims are limited to: the small-local **re-targeting** and its multiplier
thesis (§0), the **formalization** (§3–§5), the **MCP hard gate** (§6), the
**external enforcement model** (§7), and the **validation design** (§9). The name
"Dark Matter" and the "Local Intelligence Multiplier" framing are DM's; the
folder-structure architecture is ICM's.

## Relationship to Ferric (independent reference implementation)

The same ICM paper is **independently implemented** by
[Animus Ferric](https://github.com/crussella0129/Animus_Ferric) in its
`ferric-icm` crate (Ferric ADR-064) — the same five layers and Inputs·Process·
Outputs contracts — with enforcement by `ferric-guard` and a constrained
`{thought, tool, args}` loop (`ferric-loop`). As of sprint 1 (see
[`SPEC.md` §11](./SPEC.md) and [`INTEGRATION.md`](./INTEGRATION.md)), Dark Matter
**rides that runtime** rather than reimplementing it, and its own contribution
narrows to the **MCP-served knowledge layer** (§6) — the one part `ferric-icm`
lacks (it reads L3 references directly). Credit for the ICM implementation Ferric
provides is Ferric's; DM's is the knowledge layer on top.

## Citation

```bibtex
@misc{vanclief2026icm,
  title  = {Interpretable Context Methodology: Folder Structure as Agentic Architecture},
  author = {Van Clief, Jake and McDermott, David},
  year   = {2026},
  eprint = {2603.16021},
  archivePrefix = {arXiv},
  primaryClass  = {cs.AI},
  url    = {https://arxiv.org/abs/2603.16021}
}
```
