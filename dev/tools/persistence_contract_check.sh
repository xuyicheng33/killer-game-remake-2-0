#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

SAVE_SERVICE_FILE="runtime/modules/persistence/save_service.gd"
SERIALIZER_FILE="runtime/modules/persistence/run_state_serializer.gd"
DESERIALIZER_FILE="runtime/modules/persistence/run_state_deserializer.gd"

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
  echo "  pattern: $pattern" >&2
  echo "  file: $file" >&2
  fail "$label"
}

echo "[persistence_contract] checking save version constants..."

# 检查 SAVE_VERSION 常量存在
assert_has '^const SAVE_VERSION := [0-9]+' \
  "$SAVE_SERVICE_FILE" \
  "SAVE_VERSION constant exists"

# 检查 MIN_COMPAT_VERSION 常量存在
assert_has '^const MIN_COMPAT_VERSION := [0-9]+' \
  "$SAVE_SERVICE_FILE" \
  "MIN_COMPAT_VERSION constant exists"

echo "[persistence_contract] checking run_state serialization..."

# 检查 _serialize_run_state 包含 card_removal_count 字段
assert_has 'payload\["card_removal_count"\] = run_state\.card_removal_count' \
  "$SERIALIZER_FILE" \
  "_serialize_run_state includes card_removal_count field"

# 检查 _deserialize_run_state 恢复 card_removal_count 字段
assert_has 'restored\.card_removal_count = maxi\(0, int\(payload\.get\("card_removal_count"' \
  "$DESERIALIZER_FILE" \
  "_deserialize_run_state restores card_removal_count field"

echo "[persistence_contract] checking player stats serialization..."

# 检查 _serialize_player_stats 包含 statuses 字段（来自 get_status_snapshot）
assert_has 'data\["statuses"\] = stats\.get_status_snapshot\(\)' \
  "$SERIALIZER_FILE" \
  "_serialize_player_stats includes statuses field from get_status_snapshot"

echo "[persistence_contract] checking player stats deserialization..."

# 检查 _apply_player_stats 包含 statuses 恢复逻辑
assert_has 'stats\.set_status\(status_id, stacks\)' \
  "$DESERIALIZER_FILE" \
  "_apply_player_stats calls set_status for status restoration"

# 检查读取 statuses 时对旧存档有默认空字典兜底
assert_has 'stats_data\.get\("statuses", \{\}\)' \
  "$DESERIALIZER_FILE" \
  "_apply_player_stats has default empty dict for v1 compatibility"

echo "[persistence_contract] all checks passed."
