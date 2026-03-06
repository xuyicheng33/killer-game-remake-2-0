#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

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
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    pass "$label"
    return
  fi
  fail "$label (missing pattern '$pattern' in '$file')"
}

assert_not_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    echo "[context] unexpected matches in $file:" >&2
    grep -En "$pattern" "$file" >&2 || true
    fail "$label (found forbidden pattern '$pattern' in '$file')"
  fi
  pass "$label"
}

echo "[tooltip_overlay_contract] checking unified tooltip signal..."
assert_has 'signal tooltip_requested\(payload: Dictionary\)' runtime/global/events.gd "Events exposes tooltip_requested"
assert_has 'signal tooltip_requested\(payload: Dictionary\)' runtime/global/tooltip_events.gd "TooltipEvents exposes tooltip_requested"

echo "[tooltip_overlay_contract] checking custom tooltip emitters avoid native tooltip_text..."
assert_not_has '\.tooltip_text[[:space:]]*=' runtime/scenes/ui/relic_potion_ui.gd "relic_potion_ui does not set native tooltip_text"
assert_not_has '\.tooltip_text[[:space:]]*=' runtime/scenes/reward/reward_screen.gd "reward_screen does not set native tooltip_text"
assert_not_has '\.tooltip_text[[:space:]]*=' runtime/scenes/shop/shop_screen.gd "shop_screen does not set native tooltip_text"

echo "[tooltip_overlay_contract] checking single tooltip scene ownership..."
other_tooltip_refs="$(rg -n 'runtime/scenes/ui/tooltip\.tscn' runtime/scenes | grep -v '^runtime/scenes/app/app.tscn:' || true)"
if [[ -n "$other_tooltip_refs" ]]; then
  echo "[context] unexpected tooltip refs:" >&2
  echo "$other_tooltip_refs" >&2
  fail "tooltip.tscn must only be instantiated by app.tscn"
fi
pass "tooltip.tscn is only instantiated by app.tscn"

echo "[tooltip_overlay_contract] checking route-aware overlay wiring..."
assert_has 'enum OverlayMode' runtime/scenes/app/app.gd "app defines overlay mode enum"
assert_has 'relic_potion_ui\.set_overlay_mode' runtime/scenes/app/app.gd "app drives relic_potion_ui overlay mode"
assert_has 'func set_overlay_mode\(' runtime/scenes/ui/relic_potion_ui.gd "relic_potion_ui exposes set_overlay_mode"

echo "[tooltip_overlay_contract] all checks passed."
