#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

UI_DIR="runtime/scenes/ui"
STATS_UI_FILE="runtime/scenes/ui/stats_ui.gd"
RELIC_POTION_UI_FILE="runtime/scenes/ui/relic_potion_ui.gd"
STATS_ADAPTER_FILE="runtime/modules/ui_shell/adapter/stats_ui_adapter.gd"
RELIC_POTION_ADAPTER_FILE="runtime/modules/ui_shell/adapter/relic_potion_ui_adapter.gd"

fail() {
  local message="$1"
  echo "[FAIL] $message" >&2
  exit 1
}

pass() {
  local message="$1"
  echo "[PASS] $message"
}

assert_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -n "$pattern" "$file" >/dev/null; then
    pass "$label"
    return
  fi
  fail "$label (missing pattern '$pattern' in '$file')"
}

assert_not_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -n "$pattern" "$file" >/dev/null; then
    echo "[context] unexpected matches in $file:" >&2
    rg -n "$pattern" "$file" >&2 || true
    fail "$label (found forbidden pattern '$pattern' in '$file')"
  fi
  pass "$label"
}

echo "[ui_shell_contract] checking forbidden direct RunState writes under runtime/scenes/ui..."
forbidden_pattern='run_state[[:space:]]*\.[[:space:]]*(set_|add_|remove_|clear_|advance_|mark_|apply_)'
forbidden_matches="$(rg -n --glob '*.gd' "$forbidden_pattern" "$UI_DIR" || true)"
if [[ -n "$forbidden_matches" ]]; then
  echo "[context] forbidden direct RunState writes:" >&2
  printf '%s\n' "$forbidden_matches" >&2
  fail "runtime/scenes/ui must not call run_state.set_/add_/remove_/clear_/advance_/mark_/apply_ directly"
fi
pass "no forbidden run_state direct writes in runtime/scenes/ui"

echo "[ui_shell_contract] checking migrated pages are wired through adapter + viewmodel..."
assert_has 'runtime/modules/ui_shell/adapter/stats_ui_adapter\.gd' "$STATS_UI_FILE" "stats_ui uses stats adapter"
assert_has 'runtime/modules/ui_shell/viewmodel/stats_view_model\.gd' "$STATS_ADAPTER_FILE" "stats adapter uses stats viewmodel"
assert_not_has 'BuffSystem\.get_instance\(' "$STATS_UI_FILE" "stats_ui does not directly query BuffSystem"

assert_has 'runtime/modules/ui_shell/adapter/relic_potion_ui_adapter\.gd' "$RELIC_POTION_UI_FILE" "relic_potion_ui uses relic_potion adapter"
assert_has 'runtime/modules/ui_shell/viewmodel/relic_potion_view_model\.gd' "$RELIC_POTION_ADAPTER_FILE" "relic_potion adapter uses relic_potion viewmodel"
assert_not_has 'relic_potion_system[[:space:]]*\.[[:space:]]*use_potion\(' "$RELIC_POTION_UI_FILE" "relic_potion_ui does not directly call relic_potion_system.use_potion"

echo "[ui_shell_contract] all checks passed."
