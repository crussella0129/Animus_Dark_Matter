# L3 — Reference Knowledge Vault

This directory is the **L3 knowledge vault**. It holds mirrored domain
documentation as chunked, clean (HTML-free) markdown.

> **This content is served to the model ONLY through the MCP knowledge server
> (see [`SPEC.md` §6](../../SPEC.md#6-the-mcp-knowledge-layer)). The model and the
> harness NEVER read these files directly.** That gate is invariant **INV-3**
> ([`SPEC.md` §5](../../SPEC.md#5-invariants)): the only ways in are
> `resources/read` on a `ref://<target>/…#<chunk>` URI, or the
> `fetch_isolated_context` search Tool — and a chunk is served only if its target
> is in the **active stage's** reference bindings from `01_routing/ROUTING.md`.

## How this gets populated

The `mirror` ingestion pipeline (**s1**, contract in `SPEC.md` §6.5) fills this
directory:

```
target descriptor  →  fetch  →  strip to clean markdown  →  chunk (by heading/size)
                   →  assign ref:// URIs  →  index for search
```

producing addressable, searchable Resources under `03_reference/<target>/`.

In the bare template this directory is intentionally empty — instantiate one
subdirectory per reference corpus you mirror (e.g. `03_reference/qwen-docs/`).
Do **not** hand-place files you expect the model to read as plain files; if it
is not reachable through the MCP server, the model cannot (and must not) see it.
