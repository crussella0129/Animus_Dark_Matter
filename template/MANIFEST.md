# Dark Matter Workspace Template

A canonical, instantiable **Animus Dark Matter** workspace. Its on-disk shape is
normative — it is the layout defined in [`SPEC.md` §8](../SPEC.md#8-canonical-directory-layout),
and `scripts/verify-spec.sh` checks that this template and the spec agree.

Copy this directory to start a new workspace, then: edit `00_identity/`, author
your `01_routing/` matrix, add stages under `02_stages/`, mirror your reference
corpora into `03_reference/` (via the ingestion pipeline), and run it under the
enforcement harness (both the harness and MCP server arrive in **s1**).

## The five layers

| Dir | Layer | Purpose | Access (see SPEC §3) |
|-----|-------|---------|----------------------|
| `00_identity/` | **L0** | System identity & execution constraints (`IDENTITY.md`) | read-only, **pinned** into context for the whole run |
| `01_routing/` | **L1** | Routing matrix (`ROUTING.md`): problem signature → ordered stage sequence + per-stage reference bindings | read-only; consulted at `ROUTING` and on each transition |
| `02_stages/` | **L2** | One numbered folder per stage; each holds a `CONTRACT.md` (`Inputs · Process · Outputs`) | read-only; **only the active stage's** contract is readable |
| `03_reference/` | **L3** | Knowledge vault — chunked clean-markdown | **served ONLY via MCP; never read directly** (see its `README.md`) |
| `04_artifacts/` | **L4** | Working artifacts / per-stage outputs | **the only writable layer**; the sole inter-stage channel |

## The two invariants worth remembering here

- **Only `04_artifacts/` is writable at runtime** (INV-2). Everything else is
  immutable support.
- **`03_reference/` is reached only through the MCP knowledge server** (INV-3),
  never by a direct file read.

See [`SPEC.md` §5](../SPEC.md#5-invariants) for the full invariant set and
[`SPEC.md` §4](../SPEC.md#4-the-icm-state-machine) for the state machine that
sequences the stages.
