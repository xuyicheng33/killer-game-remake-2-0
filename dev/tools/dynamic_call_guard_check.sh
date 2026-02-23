#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ALLOWLIST=(
  "runtime/modules/relic_potion/relic_potion_system.gd"
  "runtime/modules/relic_potion/relic_registry.gd"
  "runtime/modules/effect_engine/effect_stack_engine.gd"
  "runtime/modules/relic_potion/contracts/battle_session_port.gd"
  "runtime/modules/persistence/run_state_deserializer.gd"
)

is_allowlisted() {
  local file="$1"
  for item in "${ALLOWLIST[@]}"; do
    if [[ "$file" == "$item" ]]; then
      return 0
    fi
  done
  return 1
}

echo "[dynamic_call_guard] checking dynamic call usage..."

# 场景层禁止动态 call
scene_calls="$(rg -n --glob '*.gd' '\.call\(' runtime/scenes || true)"
if [[ -n "$scene_calls" ]]; then
  echo "[dynamic_call_guard] failed: dynamic call is forbidden in runtime/scenes" >&2
  echo "$scene_calls" >&2
  exit 1
fi

violations=0
while IFS= read -r line; do
  file="${line%%:*}"
  if is_allowlisted "$file"; then
    continue
  fi
  if [[ "$violations" -eq 0 ]]; then
    echo "[dynamic_call_guard] forbidden dynamic call entries:" >&2
  fi
  echo "  $line" >&2
  violations=$((violations + 1))
done < <(
  rg -n --glob '*.gd' '\.call\(' runtime/modules || true
)

if [[ "$violations" -gt 0 ]]; then
  echo "[dynamic_call_guard] failed: found $violations disallowed dynamic call entries." >&2
  exit 1
fi

echo "[dynamic_call_guard] passed."
