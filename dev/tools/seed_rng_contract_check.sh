#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

CARD_PILE_FILE="content/custom_resources/card_pile.gd"
PLAYER_HANDLER_FILE="runtime/scenes/player/player_handler.gd"
RUN_LIFECYCLE_FILE="runtime/modules/run_flow/run_lifecycle_service.gd"

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
    echo "  [context] unexpected matches in $file:" >&2
    grep -En "$pattern" "$file" >&2 || true
    fail "$label (found forbidden pattern '$pattern' in '$file')"
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
  echo "  pattern: $pattern" >&2
  echo "  file: $file" >&2
  fail "$label"
}

echo "[seed_rng_contract] checking card_pile.gd shuffle_with_rng implementation..."

# 检查 card_pile.gd 存在 shuffle_with_rng(stream_key) 方法
assert_has 'func shuffle_with_rng\(stream_key: String\)' \
  "$CARD_PILE_FILE" \
  "card_pile.gd must have shuffle_with_rng(stream_key: String) method"

# 检查 shuffle_with_rng 内使用 RunRng（而非随机系统默认 shuffle）
assert_has 'RunRng\.randi_range\(stream_key' \
  "$CARD_PILE_FILE" \
  "shuffle_with_rng must use RunRng.randi_range with stream_key"

echo "[seed_rng_contract] checking player_handler.gd battle shuffle calls..."

# 检查 start_battle 使用 shuffle_with_rng("battle_start_shuffle")
assert_has 'shuffle_with_rng\("battle_start_shuffle"\)' \
  "$PLAYER_HANDLER_FILE" \
  "player_handler.start_battle must use shuffle_with_rng(\"battle_start_shuffle\")"

# 检查 reshuffle_deck_from_discard 使用 shuffle_with_rng("reshuffle_discard")
assert_has 'shuffle_with_rng\("reshuffle_discard"\)' \
  "$PLAYER_HANDLER_FILE" \
  "player_handler.reshuffle_deck_from_discard must use shuffle_with_rng(\"reshuffle_discard\")"

echo "[seed_rng_contract] checking run_lifecycle_service.gd RNG restore logic..."

# 检查 try_load_saved_run 内存在 restore_run_state(...) 逻辑
assert_has 'restore_run_state\(' \
  "$RUN_LIFECYCLE_FILE" \
  "run_lifecycle_service.try_load_saved_run must call restore_run_state"

# 检查 restore 失败时有 begin_run(seed) 回退逻辑
assert_has 'RUN_RNG_SCRIPT\.begin_run\(' \
  "$RUN_LIFECYCLE_FILE" \
  "run_lifecycle_service must have begin_run fallback when restore fails"

echo "[seed_rng_contract] all checks passed."
