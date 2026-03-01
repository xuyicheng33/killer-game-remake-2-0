#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

ALLOWLIST=(
  "runtime/modules/battle_loop/battle_context.gd"
  "runtime/modules/battle_loop/battle_phase_state_machine.gd"
  "runtime/modules/buff_system/buff_system.gd"
  "runtime/modules/card_system/card_zones_model.gd"
  "runtime/modules/enemy_intent/intent_rules.gd"
  "runtime/modules/relic_potion/relic_potion_system.gd"
  "runtime/modules/ui_shell/adapter/battle_ui_adapter.gd"
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

echo "[module_scene_type] checking scene-type dependencies under runtime/modules..."

violations=0
while IFS= read -r line; do
  file="${line%%:*}"
  if is_allowlisted "$file"; then
    continue
  fi
  if [[ "$violations" -eq 0 ]]; then
    echo "[module_scene_type] forbidden dependencies found:" >&2
  fi
  echo "  $line" >&2
  violations=$((violations + 1))
done < <(
  rg -n --glob '*.gd' '\b(Player|Enemy|Hand|CardUI|EnemyAction)\b|res://runtime/scenes/' runtime/modules || true
)

if [[ "$violations" -gt 0 ]]; then
  echo "[module_scene_type] failed: found $violations forbidden dependency entries." >&2
  exit 1
fi

echo "[module_scene_type] passed."
