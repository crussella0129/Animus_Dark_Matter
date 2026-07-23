# Completed Tasks Log (Append-Only)

## T-001 (sprint 0)
- **Description:** Create SPEC.md skeleton (§0–§10) + §0 abstract & formal Dark-Matter thesis + §1 provenance summary + §2 definitions/glossary.
- **Completed:** 2026-07-23T14:27:27Z
- **Files modified:** SPEC.md
- **Commit:** `c14d136`

## T-002 (sprint 0)
- **Description:** SPEC §3 — the layer model as a capability lattice (per-layer READ/FETCH/WRITE profiles, Boolean lattice over 2^P à la Denning, scope refinement, mechanism link to §0.3).
- **Completed:** 2026-07-23T14:29:26Z
- **Files modified:** SPEC.md
- **Commit:** `94367e1`

## T-003 (sprint 0)
- **Description:** SPEC §4 — the ICM state machine: tuple (Σ, σ₀, F, Δ, G, flush), states incl. IDENTITY/ROUTING/DONE + stages, configuration κ, guarded transition table (Outputs-contract guards), escalation, context-flush-on-transition, and a Mermaid stateDiagram.
- **Completed:** 2026-07-23T14:30:49Z
- **Files modified:** SPEC.md
- **Commit:** `588cdf7`

## T-004 (sprint 0)
- **Description:** SPEC §5 — invariants INV-1..6 (single active stage; write-isolation to L4; L3 MCP reference-gate; stage isolation; context minimality; routing determinism), each as a checkable condition + observer procedure + "enforced by" link.
- **Completed:** 2026-07-23T14:31:47Z
- **Files modified:** SPEC.md
- **Commit:** `94564ce`

## T-005 (sprint 0)
- **Description:** SPEC §6 — MCP knowledge-layer contract: chunks as Resources (ref:// URIs + ttlMs/cacheScope), one fetch_isolated_context Tool for search (I/O contract), server as sole L3 gatekeeper realizing INV-3 structurally, isolation/caching guarantees, and the deferred 'mirror' ingestion input→output contract.
- **Completed:** 2026-07-23T14:32:51Z
- **Files modified:** SPEC.md
- **Commit:** `0269bdf`

## T-006 (sprint 0)
- **Description:** SPEC §7 — enforcement model: harness as FSM executor assembling C_active; model reduced to a 3-action alphabet {WRITE→L4, FETCH→L3, STAGE_COMPLETE} with non-L4 writes rejected; enforcement mapping to INV-1..6; trust boundary decoupling safety from capability.
- **Completed:** 2026-07-23T14:33:54Z
- **Files modified:** SPEC.md
- **Commit:** `1ad948b`

## T-007 (sprint 0)
- **Description:** SPEC §8 canonical layout (matches template/ name-for-name) + §9 validation design (arms A0/A1/A2/A3, metrics incl. tokens-in-context/step + invariant-violations, μ̂ + gap-closure, explicit pass/falsify criteria, threats to validity) + §10 roadmap (s1 runtime, s2 validation) & six open questions. SPEC.md now complete (§0–§10, no placeholders).
- **Completed:** 2026-07-23T14:35:34Z
- **Files modified:** SPEC.md
- **Commit:** `cbe94f2`

## T-008 (sprint 0)
- **Description:** PROVENANCE.md — credits ICM/MWP (arXiv 2603.16021, Van Clief & McDermott) and Anthropic MCP as the two primary sources; lists inherited elements; enumerates DM's six departures in a delta table with SPEC cross-refs; positioning statement + BibTeX citation.
- **Completed:** 2026-07-23T14:36:18Z
- **Files modified:** PROVENANCE.md
- **Commit:** `62a9340`
