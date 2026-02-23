#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

BATTLE_FILE="runtime/scenes/battle/battle.gd"
APP_FILE="runtime/scenes/app/app.gd"

fail() {
  local message="$1"
  echo "[FAIL] $message" >&2
  exit 1
}

pass() {
  local message="$1"
  echo "[PASS] $message"
}

assert_not_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    echo "[context] unexpected matches in $file:" >&2
    grep -En "$pattern" "$file" >&2 || true
    fail "$label"
  fi
  pass "$label"
}

assert_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    pass "$label"
    return
  fi
  fail "$label"
}

echo "[battle_relic_injection] checking explicit battle session injection..."

assert_not_has 'get_nodes_in_group\("app"\)' "$BATTLE_FILE" \
  "battle.gd must not discover relic system via app group lookup"

assert_not_has 'on_battle_scene_ready' "$BATTLE_FILE" \
  "battle.gd must not invoke legacy on_battle_scene_ready path"

assert_not_has '\.call\("on_battle_scene_ready"' "$BATTLE_FILE" \
  "battle.gd must not use dynamic call for battle session injection"

assert_has 'on_battle_session_bound' "$BATTLE_FILE" \
  "battle.gd must bind relic system through on_battle_session_bound"

assert_has 'battle_scene\.set\("relic_potion_system"' "$APP_FILE" \
  "app.gd must inject relic_potion_system into battle scene explicitly"

echo "[battle_relic_injection] all checks passed."
