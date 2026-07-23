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

## T-009 (sprint 0)
- **Description:** Seeded decisions.md with ADR-0001..0005 (provenance/ICM credit; Resources+one-Tool MCP layer; external-harness enforcement; FSM×capability-lattice formal model; Rust-stdio reference runtime), each with status, context, decision, consequences, and SPEC cross-reference.
- **Completed:** 2026-07-23T14:37:12Z
- **Files modified:** decisions.md
- **Commit:** `c20c2fa`

## T-010 (sprint 0)
- **Description:** template/ scaffold skeleton — five layer directories (00_identity, 01_routing, 02_stages/00_example_stage, 03_reference, 04_artifacts), MANIFEST.md describing each layer, 03_reference/README.md stating MCP-served/never-direct-read (INV-3), and 04_artifacts/.gitkeep.
- **Completed:** 2026-07-23T14:38:56Z
- **Files modified:** template/MANIFEST.md, template/03_reference/README.md, template/04_artifacts/.gitkeep, template/{00_identity,01_routing,02_stages/00_example_stage}/.gitkeep
- **Commit:** `ba48279`

## T-011 (sprint 0)
- **Description:** Filled the template layer files with a coherent worked example (implement-against-library, the target class T*): L0 00_identity/IDENTITY.md (pinned identity + hard constraints), L1 01_routing/ROUTING.md (routing-matrix format + worked example mapping signature→stages+bindings, INV-6 determinism note), L2 02_stages/00_example_stage/CONTRACT.md (Inputs·Process·Outputs with Outputs as guard G). Removed three placeholder .gitkeeps.
- **Completed:** 2026-07-23T14:40:23Z
- **Files modified:** template/00_identity/IDENTITY.md, template/01_routing/ROUTING.md, template/02_stages/00_example_stage/CONTRACT.md (rm .gitkeeps)
- **Commit:** `e3d2676`

## T-012 (sprint 0)
- **Description:** Rewrote README.md — kept the pitch + ascii layer diagram, fixed the top run-on, added a "Why Dark Matter" section (the rotation-curve metaphor), a "How it works" section (ICM engine + MCP vault + external enforcement), a status table (s0 done / s1 / s2), a Documents section linking SPEC.md, PROVENANCE.md, template/MANIFEST.md, decisions.md, an ICM/MWP + MCP credit, and an updated Master Framework Prompt (now normative-defers-to-SPEC, Resources + external harness).
- **Completed:** 2026-07-23T14:41:48Z
- **Files modified:** README.md
- **Commit:** `19c1ffa`
