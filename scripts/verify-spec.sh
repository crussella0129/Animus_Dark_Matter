#!/usr/bin/env bash
# verify-spec.sh — mechanical spec/scaffold/ADR coherence checks for Animus Dark
# Matter (sprint s0). Runs the structural checks from sprints/s0 test-plan that
# can be mechanized; prints PASS/FAIL per check and exits non-zero if any fail.
#
# Portable POSIX bash (git-bash friendly). Patterns are ASCII to avoid locale/
# UTF-8 grep surprises even though the docs contain Unicode.
#
# Usage: bash scripts/verify-spec.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC="$ROOT/SPEC.md"
PROV="$ROOT/PROVENANCE.md"
DEC="$ROOT/decisions.md"
RDME="$ROOT/README.md"
TPL="$ROOT/template"

PASSES=0
FAILS=0
pass() { PASSES=$((PASSES + 1)); printf '  ok   %s\n' "$1"; }
fail() { FAILS=$((FAILS + 1));  printf 'FAIL   %s — %s\n' "$1" "$2"; }

# has <name> <file> <ERE-pattern> [message]
has() {
  local name="$1" file="$2" pat="$3" msg="${4:-missing /$3/}"
  if [ -f "$file" ] && grep -qE "$pat" "$file"; then pass "$name"; else fail "$name" "$msg"; fi
}
# hasfile <name> <path>
hasfile() { if [ -e "$2" ]; then pass "$1"; else fail "$1" "not found: ${2#$ROOT/}"; fi; }

# section <N> — print lines of SPEC from "## N." up to (not incl.) the next "## <digit>"
section() {
  awk -v pat="^## $1[.]" '
    $0 ~ pat {grab=1; print; next}
    grab && /^## [0-9]/ {grab=0}
    grab {print}
  ' "$SPEC"
}

echo "== Animus Dark Matter — spec verification =="
echo "root: $ROOT"

# ---- SPEC required files ----
hasfile "spec-file-exists" "$SPEC"
hasfile "provenance-file-exists" "$PROV"
hasfile "decisions-file-exists" "$DEC"
hasfile "readme-file-exists" "$RDME"

# ---- SPEC skeleton: sections 0..10 ----
missing_sec=""
for n in 0 1 2 3 4 5 6 7 8 9 10; do
  grep -qE "^## $n[.]" "$SPEC" || missing_sec="$missing_sec $n"
done
[ -z "$missing_sec" ] && pass "check_spec_skeleton" || fail "check_spec_skeleton" "missing SPEC sections:$missing_sec"

# ---- §0 thesis / §2 glossary ----
has "check_thesis_inequality" "$SPEC" 'M_small, S_DM' "§0 thesis inequality not found"
gloss_missing=""
for t in 'LIM' 'ICM' 'MWP' 'Capability lattice' 'Hard gate' 'Parametric saturation' 'Multiplier' 'Context minimality' 'Harness'; do
  grep -qE "\*\*$t" "$SPEC" || gloss_missing="$gloss_missing;$t"
done
[ -z "$gloss_missing" ] && pass "check_glossary_terms" || fail "check_glossary_terms" "glossary missing:$gloss_missing"

# ---- §3 capability lattice ----
lat_rows=""
for L in L0 L1 L2 L3 L4; do grep -qE "\*\*$L\*\*" "$SPEC" || lat_rows="$lat_rows $L"; done
[ -z "$lat_rows" ] && pass "check_lattice_table" || fail "check_lattice_table" "lattice rows missing:$lat_rows"
has "check_single_writable_layer" "$SPEC" 'only writable layer|only layer with WRITE' "no 'only writable layer' assertion"
has "check_l3_fetch_only" "$SPEC" 'MCP-fetch only' "L3 not marked 'MCP-fetch only'"

# ---- §4 state machine ----
sm_missing=""
for s in IDENTITY ROUTING DONE; do grep -qE "$s" "$SPEC" || sm_missing="$sm_missing $s"; done
[ -z "$sm_missing" ] && pass "check_state_set" || fail "check_state_set" "states missing:$sm_missing"
if grep -qiE 'guard' "$SPEC" && grep -qE 'Outputs' "$SPEC"; then pass "check_transition_guards"; else fail "check_transition_guards" "no Outputs-contract guard"; fi
has "check_context_flush" "$SPEC" 'flush' "no context-flush described"
if grep -qE '```mermaid' "$SPEC" && grep -qE 'stateDiagram' "$SPEC"; then pass "check_mermaid_present"; else fail "check_mermaid_present" "no mermaid stateDiagram"; fi

# ---- §5 invariants defined ----
inv_missing=""
for k in 1 2 3 4 5 6; do grep -qE "^### INV-$k" "$SPEC" || inv_missing="$inv_missing $k"; done
[ -z "$inv_missing" ] && pass "check_invariants_defined" || fail "check_invariants_defined" "INV headings missing:$inv_missing"

# ---- §6 MCP layer ----
if grep -qE 'ref://' "$SPEC" && grep -qE 'ttlMs' "$SPEC" && grep -qE 'cacheScope' "$SPEC"; then pass "check_resources_scheme"; else fail "check_resources_scheme" "ref:// / ttlMs / cacheScope not all present"; fi
has "check_single_tool" "$SPEC" 'fetch_isolated_context' "search Tool not named"
has "check_gatekeeper" "$SPEC" 'gatekeeper' "MCP server not named as gatekeeper"
if grep -qiE 'out of scope for s0' "$SPEC" && grep -qE 'mirror' "$SPEC"; then pass "check_ingestion_scoped"; else fail "check_ingestion_scoped" "ingestion not scoped-out / 'mirror' missing"; fi

# ---- §7 enforcement ----
has "check_harness_executor" "$SPEC" 'executor' "harness not described as executor"
if grep -qE 'STAGE_COMPLETE' "$SPEC" && grep -qE 'FETCH' "$SPEC" && grep -qE 'WRITE' "$SPEC"; then pass "check_action_alphabet"; else fail "check_action_alphabet" "3-action alphabet not all present"; fi
has "check_write_rejection" "$SPEC" 'rejected' "no write-rejection statement"

# ---- §8 layout / §9 validation / §10 roadmap ----
lay_missing=""
for d in 00_identity 01_routing 02_stages 03_reference 04_artifacts; do
  section 8 | grep -qE "$d" || lay_missing="$lay_missing $d"
done
[ -z "$lay_missing" ] && pass "check_layout_section" || fail "check_layout_section" "§8 missing dirs:$lay_missing"
if section 9 | grep -qE 'A0' && section 9 | grep -qE 'A1' && section 9 | grep -qE 'A2' && section 9 | grep -qiE 'falsif'; then pass "check_validation_arms"; else fail "check_validation_arms" "§9 arms/falsification incomplete"; fi
if section 10 | grep -qiE 's1' && section 10 | grep -qiE 's2'; then pass "check_roadmap"; else fail "check_roadmap" "§10 does not assign s1/s2"; fi

# ---- INTEGRATION: every INV-<n> referenced in SPEC is defined by a heading ----
inv_bad=""
for n in $(grep -oE 'INV-[0-9]+' "$SPEC" | sed 's/INV-//' | sort -un); do
  grep -qE "^### INV-$n" "$SPEC" || inv_bad="$inv_bad INV-$n"
done
[ -z "$inv_bad" ] && pass "test_inv_refs_resolve" || fail "test_inv_refs_resolve" "referenced but undefined:$inv_bad"

# ---- INTEGRATION: each layer L0..L4 appears in §3, §4 and §8 ----
layer_bad=""
for L in L0 L1 L2 L3 L4; do
  section 3 | grep -qE "$L" && section 4 | grep -qE "$L" && section 8 | grep -qE "$L" \
    || layer_bad="$layer_bad $L"
done
[ -z "$layer_bad" ] && pass "test_layers_appear_everywhere" || fail "test_layers_appear_everywhere" "layer(s) not in §3&§4&§8:$layer_bad"

# ---- INTEGRATION: mermaid states match prose Σ ----
mm="$(awk '/```mermaid/{g=1;next} /```/{if(g){g=0}} g{print}' "$SPEC")"
mm_bad=""
for st in IDENTITY ROUTING DONE Stage_1 Stage_n; do
  printf '%s' "$mm" | grep -qE "$st" || mm_bad="$mm_bad $st"
done
[ -z "$mm_bad" ] && pass "test_mermaid_states_match" || fail "test_mermaid_states_match" "diagram missing states:$mm_bad"

# ---- PROVENANCE ----
if grep -qE '2603\.16021' "$PROV" && grep -qiE 'model context protocol|MCP' "$PROV"; then pass "check_provenance_citations"; else fail "check_provenance_citations" "missing arXiv 2603.16021 or MCP"; fi
if grep -qiE 'departure' "$PROV" && grep -qiE 'small local' "$PROV"; then pass "check_delta_table"; else fail "check_delta_table" "delta table incomplete"; fi

# ---- decisions.md: five ADRs + cross-refs ----
adr_missing=""
for i in 1 2 3 4 5; do grep -qE "^## ADR-000$i" "$DEC" || adr_missing="$adr_missing 000$i"; done
[ -z "$adr_missing" ] && pass "check_five_adrs" || fail "check_five_adrs" "missing ADRs:$adr_missing"
xref="$(grep -cE '^- \*\*SPEC:\*\*' "$DEC")"
[ "$xref" -ge 5 ] && pass "check_adr_crossrefs" || fail "check_adr_crossrefs" "only $xref/5 ADRs cross-ref SPEC"

# ---- template (Component C) ----
tdir_missing=""
for d in 00_identity 01_routing 02_stages 03_reference 04_artifacts; do
  [ -d "$TPL/$d" ] || tdir_missing="$tdir_missing $d"
done
[ -z "$tdir_missing" ] && pass "check_template_dirs" || fail "check_template_dirs" "missing template dirs:$tdir_missing"
if grep -qiE 'never read|only through the mcp|served .*only.* mcp' "$TPL/03_reference/README.md"; then pass "check_l3_readme_note"; else fail "check_l3_readme_note" "L3 README lacks gate note"; fi
man_missing=""
for d in 00_identity 01_routing 02_stages 03_reference 04_artifacts; do grep -qE "$d" "$TPL/MANIFEST.md" || man_missing="$man_missing $d"; done
[ -z "$man_missing" ] && pass "check_manifest" || fail "check_manifest" "MANIFEST missing layer(s):$man_missing"
has "check_identity_file" "$TPL/00_identity/IDENTITY.md" 'constraint' "IDENTITY.md lacks constraints"
if grep -qE 'signature' "$TPL/01_routing/ROUTING.md" && grep -qE 'stages' "$TPL/01_routing/ROUTING.md" && grep -qE 'bindings' "$TPL/01_routing/ROUTING.md"; then pass "check_routing_format"; else fail "check_routing_format" "ROUTING.md lacks signature/stages/bindings"; fi
CON="$TPL/02_stages/00_example_stage/CONTRACT.md"
if grep -qE '^## Inputs' "$CON" && grep -qE '^## Process' "$CON" && grep -qE '^## Outputs' "$CON"; then pass "check_contract_sections"; else fail "check_contract_sections" "CONTRACT.md lacks Inputs/Process/Outputs"; fi

# ---- INTEGRATION: template layout == SPEC §8 (name-for-name, both directions) ----
t2s_bad=""
for d in 00_identity 01_routing 02_stages 03_reference 04_artifacts; do
  { [ -d "$TPL/$d" ] && section 8 | grep -qE "$d"; } || t2s_bad="$t2s_bad $d"
done
[ -z "$t2s_bad" ] && pass "test_template_matches_spec8" || fail "test_template_matches_spec8" "template/§8 mismatch:$t2s_bad"

# ---- README (Component D) ----
if grep -qE 'Dark Matter' "$RDME" && grep -qE 'SPEC\.md' "$RDME" && grep -qE 'PROVENANCE\.md' "$RDME"; then pass "check_readme_sections"; else fail "check_readme_sections" "README missing why-name / SPEC / PROVENANCE"; fi
if grep -qiE 'formalized|formal specification' "$RDME" && grep -qiE 's1' "$RDME"; then pass "check_readme_status"; else fail "check_readme_status" "README status missing"; fi

# ---- INTEGRATION: README entrypoint links resolve ----
test_readme_entrypoint="ok"
for tgt in "$SPEC" "$PROV"; do grep -qE "$(basename "$tgt")" "$RDME" && [ -f "$tgt" ] || test_readme_entrypoint="bad"; done
[ "$test_readme_entrypoint" = ok ] && pass "test_readme_entrypoint" || fail "test_readme_entrypoint" "README does not link SPEC/PROVENANCE that exist"

# ---- link resolution across doc files (strip #fragments; skip http/# ) ----
link_bad=""
for f in "$RDME" "$SPEC" "$ROOT/INTEGRATION.md" "$TPL/MANIFEST.md" "$TPL/03_reference/README.md"; do
  [ -f "$f" ] || continue
  base="$(dirname "$f")"
  while IFS= read -r lnk; do
    case "$lnk" in http://*|https://*|\#*|"") continue ;; esac
    path="${lnk%%#*}"                     # strip anchor
    [ -z "$path" ] && continue            # pure in-page anchor
    ( cd "$base" && [ -e "$path" ] ) || link_bad="$link_bad ${f#$ROOT/}:$lnk"
  done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done
[ -z "$link_bad" ] && pass "check_readme_links" || fail "check_readme_links" "dangling:$link_bad"

# =================== s1 re-scope checks (Component A–E) ===================
INTEG="$ROOT/INTEGRATION.md"

# ---- SPEC: scope banner + §11 + reframe markers ----
if grep -qiE 'scope \(s1\)' "$SPEC" && grep -qiE 'knowledge layer' "$SPEC" && grep -qE 'Ferric' "$SPEC"; then pass "check_scope_banner"; else fail "check_scope_banner" "SPEC scope banner missing"; fi
if grep -qE '^## 11[.]' "$SPEC" && grep -qE 'ferric-icm' "$SPEC" && grep -qE 'ferric-guard' "$SPEC" && grep -qE 'ferric-loop' "$SPEC"; then pass "check_relationship_section"; else fail "check_relationship_section" "§11 missing or lacks ferric-* crates"; fi
reframe_bad=""
for n in 3 4 5 7; do section "$n" | grep -qE 'enforced by the runtime' || reframe_bad="$reframe_bad §$n"; done
[ -z "$reframe_bad" ] && pass "check_reframe_notes" || fail "check_reframe_notes" "missing reframe marker in:$reframe_bad"

# ---- SPEC §10 roadmap ----
if section 10 | grep -qiE 'MCP knowledge server' && section 10 | grep -qE 'mirror'; then pass "check_roadmap_s2_build"; else fail "check_roadmap_s2_build" "§10 s2 build (MCP knowledge server + mirror) missing"; fi
if section 10 | grep -qE 'fetch_reference' && section 10 | grep -qE 'compose_stage'; then pass "check_roadmap_ferric_sprint"; else fail "check_roadmap_ferric_sprint" "§10 Ferric sprint (fetch_reference + compose_stage) missing"; fi
if section 10 | grep -qiE 'enforcement harness'; then fail "check_roadmap_no_harness" "§10 still claims DM builds an enforcement harness"; else pass "check_roadmap_no_harness"; fi

# ---- INTEGRATION.md ----
hasfile "integration-file-exists" "$INTEG"
has "check_integration_tool" "$INTEG" 'fetch_reference' "fetch_reference tool descriptor missing"
if grep -qE 'compose_stage' "$INTEG" && grep -qE 'references/' "$INTEG"; then pass "check_integration_compose"; else fail "check_integration_compose" "compose_stage change not described"; fi
if grep -qiE 'standalone' "$INTEG" && grep -qE 'MCP server' "$INTEG"; then pass "check_integration_standalone"; else fail "check_integration_standalone" "standalone MCP server not described"; fi
if grep -qiE 'repo boundary' "$INTEG" && grep -qE 'Animus_Ferric' "$INTEG"; then pass "check_integration_boundary"; else fail "check_integration_boundary" "repo boundary not stated"; fi

# ---- decisions.md: new ADRs + amend notes; PROVENANCE credit ----
adr1_missing=""
for i in 6 7 8; do grep -qE "^## ADR-000$i" "$DEC" || adr1_missing="$adr1_missing 000$i"; done
[ -z "$adr1_missing" ] && pass "check_new_adrs" || fail "check_new_adrs" "missing ADRs:$adr1_missing"
[ "$(grep -cE 'amended by ADR-0006/0008' "$DEC")" -ge 2 ] && pass "check_adr_amend_notes" || fail "check_adr_amend_notes" "ADR-0003/0005 amend notes missing (need 2)"
has "check_provenance_ferric" "$PROV" 'ferric-icm' "PROVENANCE lacks ferric-icm credit"

# ---- README reposition ----
if grep -qiE 'knowledge layer' "$RDME" && grep -qE 'INTEGRATION\.md' "$RDME"; then pass "check_readme_reposition"; else fail "check_readme_reposition" "README not repositioned / no INTEGRATION link"; fi
if grep -qiE 'knowledge server' "$RDME"; then pass "check_readme_status_s2"; else fail "check_readme_status_s2" "README status s2 (knowledge server) missing"; fi

# ---- INTEGRATION coherence ----
if grep -qE '^## 6[.]' "$SPEC" && grep -qE '^## 9[.]' "$SPEC"; then pass "test_s0_survivors_intact"; else fail "test_s0_survivors_intact" "§6/§9 missing after re-scope"; fi
FERRIC=""
for cand in "$ROOT/../Animus_Ferric" "/c/Users/charl/Animus_Ferric" "$HOME/Animus_Ferric"; do
  [ -d "$cand" ] && FERRIC="$cand" && break
done
if [ -n "$FERRIC" ]; then
  fcite_bad=""
  for f in crates/ferric-icm/src/lib.rs crates/ferric-loop/src/grammar.rs; do
    [ -f "$FERRIC/$f" ] || fcite_bad="$fcite_bad $f"
  done
  [ -z "$fcite_bad" ] && pass "test_ferric_citations_resolve" || fail "test_ferric_citations_resolve" "cited Ferric paths absent:$fcite_bad"
else
  pass "test_ferric_citations_resolve (skipped: Ferric repo not present)"
fi

# ---- summary ----
echo "-------------------------------------------"
echo "PASS: $PASSES   FAIL: $FAILS"
if [ "$FAILS" -gt 0 ]; then echo "RESULT: FAIL"; exit 1; fi
echo "RESULT: PASS (check_verifier_green)"; exit 0
