# Dark Matter × Ferric — Integration Contract

Dark Matter builds the **knowledge layer** (SPEC §6); the ICM runtime is
[Animus Ferric](https://github.com/crussella0129/Animus_Ferric) (SPEC §11). This
document is the concrete contract the s2 build (DM) and the coordinated Ferric
sprint consume. It has **two surfaces over one store**: a Ferric built-in tool,
and a standalone MCP server.

```
        DM knowledge store  ( chunks + `mirror` ingestion )
          |                                   |
   surface 1: fetch_reference          surface 2: MCP server
   (Ferric built-in tool)              (ref:// Resources + fetch_isolated_context)
          |                                   |
     ferric-loop action ring            any MCP-client agent
     (small local model)                (Claude Desktop/Code, other agents)
```

## Surface 1 — the `fetch_reference` Ferric built-in tool (primary seam)

Ferric tools are `ferric_provider::ToolDescriptor { name, description, input_schema }`
(a JSON-Schema), surfaced into the constrained action grammar by
`ferric_loop::grammar::action_schema` (the `{thought, tool, args}` `anyOf`). DM
adds exactly one descriptor:

```json
{
  "name": "fetch_reference",
  "description": "Fetch the exact reference chunk(s) this step needs from the L3 knowledge vault. Returns clean-markdown text only. Prefer a specific query/section over a broad sweep.",
  "input_schema": {
    "type": "object",
    "properties": {
      "target":  { "type": "string",  "description": "reference corpus bound to this stage (from ROUTING/CONTEXT bindings)" },
      "query":   { "type": "string",  "description": "semantic/keyword search within target" },
      "section": { "type": "string",  "description": "explicit heading/anchor (optional)" },
      "k":       { "type": "integer", "description": "max chunks (default 4)" }
    },
    "required": ["target"]
  }
}
```

**Request / response (identical to SPEC §6.2).** The model emits, through the
existing constrained grammar:

```json
{"thought":"I need the current spawn API","tool":"fetch_reference","args":{"target":"qwen-docs","query":"tokio spawn"}}
```

Ferric routes the `ToolCall` to DM's store, which returns:

```json
{ "chunks": [ {"uri":"ref://qwen-docs/runtime.md#12","text":"…","score":0.87} ], "truncated": false }
```

folded back as a tool result. **Only the returned chunks enter `C_active`** — the
token-minimality win (SPEC §0.3 / INV-5). `fetch_reference` (here) and
`fetch_isolated_context` (SPEC §6.2 / surface 2) are the **same operation** with
the same contract.

**Binding enforcement.** `target` must be in the active stage's reference
bindings (`ROUTING.md` / stage `CONTEXT.md`); an out-of-binding fetch is refused
(SPEC INV-3). Ferric's `ferric-guard` already contains all file access; DM's
store enforces the per-stage binding.

## Surface 2 — the standalone MCP server

The same store is exposed as a **stdio MCP server** (SPEC §6): reference chunks as
**Resources** (`ref://…` URIs, `ttlMs`/`cacheScope` caching) plus the
`fetch_isolated_context` **Tool**. Any MCP-client agent consumes it identically —
so DM is usable **standalone**, not only through Ferric. (Ferric today is an MCP
*server*, not a client, so surface 1 — a built-in tool — is the cheaper seam for
the Ferric path; surface 2 serves everyone else.)

## The Ferric-side change — `ferric-icm::compose_stage`

Today `compose_stage` (`crates/ferric-icm/src/lib.rs`) resolves each stage's
declared Layer-3 `references/` inputs and **folds the whole file content into the
composed prompt** (`read_input` → `section(&mut prompt, …)`). The change:

1. **Stop pre-folding L3 `references/`** into the stage prompt. (Keep folding L4
   working artifacts — those are the per-run inputs a stage must see.)
2. **Register the `fetch_reference` tool** for the stage, scoped to that stage's
   L3 bindings, and let the model pull the exact chunk it needs mid-stage through
   the **existing** constrained action loop.

Net: L3 moves from "always fully in context" to "fetched on demand" — a smaller,
pristine `C_active` (SPEC §0.3 / INV-5). **No new protocol** — it is one more tool
in the ring. This is a Ferric-repo change (a `ferric-icm` + `ferric-tools`
sprint), specified here and coordinated with DM.

## Repo boundary

- **Dark Matter (`Animus_Dark_Matter`)** — its own **light repo**: the knowledge
  store, the `mirror` ingestion pipeline, the MCP knowledge server, and the
  `fetch_reference` backend (a small crate Ferric can depend on, or a subprocess).
  Ships `SPEC.md`.
- **Ferric (`Animus_Ferric`)** — gains **one built-in tool** (`fetch_reference`)
  plus the `compose_stage` tweak. The loop, guard, OpenAI valve, and the
  constrained **JSONL engine stay in Ferric, untouched** (SPEC §11, ADR-0007). DM
  never reimplements a runtime.

## What this unlocks

First real end-to-end (SPEC §9): a Ferric ICM stage, driving a small local model,
emits `fetch_reference` and receives an L3 chunk from the DM store — measured
against the whole-file-folding baseline for the token-minimality claim.
