#!/usr/bin/env bash
# scene_nested_state_write_check.sh - 场景层禁止直接写嵌套状态门禁
# 目的：防止通过 run_state.player_stats.* / run_state.map_graph.* / run_state.relics|potions.* 绕过门禁
# 用法：bash dev/tools/scene_nested_state_write_check.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# ========== 辅助函数 ==========
fail() {
  local message="$1"
  echo "[FAIL] $message" >&2
  exit 1
}

pass() {
  local message="$1"
  echo "[PASS] $message"
}

# 检查是否有匹配的文件
has_matches() {
  local pattern="$1"
  local path="$2"
  if grep -rqE "$pattern" "$path" 2>/dev/null; then
    return 0
  fi
  return 1
}

# 报告匹配的文件和行号
report_matches() {
  local pattern="$1"
  local path="$2"
  echo "  [context] forbidden nested state writes found:" >&2
  grep -rnE "$pattern" "$path" 2>/dev/null | head -20 >&2 || true
}

SCENES_DIR="runtime/scenes"

echo "[scene_nested_state_write] checking forbidden nested state write patterns in runtime/scenes..."

# ========== 1. 检查 player_stats 方法调用 ==========
echo "[scene_nested_state_write] 1. 检查 player_stats 写入方法调用..."

# run_state.player_stats.(set_|add_|remove_|clear_|apply_|heal|take_damage|gain_block|set_status)
PLAYER_STATS_METHOD_PATTERN='run_state\.player_stats\.(set_|add_|remove_|clear_|apply_|heal|take_damage|gain_block|set_status)\w*\('
if has_matches "$PLAYER_STATS_METHOD_PATTERN" "$SCENES_DIR"; then
  report_matches "$PLAYER_STATS_METHOD_PATTERN" "$SCENES_DIR"
  fail "发现 run_state.player_stats 禁止的方法调用"
fi
pass "无 run_state.player_stats 禁止的方法调用"

# ========== 2. 检查 map_graph 方法调用 ==========
echo "[scene_nested_state_write] 2. 检查 map_graph 写入方法调用..."

# run_state.map_graph.(set_|add_|remove_|clear_|advance_)
MAP_GRAPH_METHOD_PATTERN='run_state\.map_graph\.(set_|add_|remove_|clear_|advance_)\w*\('
if has_matches "$MAP_GRAPH_METHOD_PATTERN" "$SCENES_DIR"; then
  report_matches "$MAP_GRAPH_METHOD_PATTERN" "$SCENES_DIR"
  fail "发现 run_state.map_graph 禁止的方法调用"
fi
pass "无 run_state.map_graph 禁止的方法调用"

# ========== 3. 检查 relics/potions 集合操作 ==========
echo "[scene_nested_state_write] 3. 检查 relics/potions 集合操作..."

# run_state.(relics|potions).(append|erase|clear|push_|pop_|insert|remove)
COLLECTION_PATTERN='run_state\.(relics|potions|deck|discard|exhausted|consumables)\.(append|erase|clear|push_|pop_|insert|remove)\('
if has_matches "$COLLECTION_PATTERN" "$SCENES_DIR"; then
  report_matches "$COLLECTION_PATTERN" "$SCENES_DIR"
  fail "发现 run_state.relics/potions 禁止的集合操作"
fi
pass "无 run_state.relics/potions 禁止的集合操作"

# ========== 4. 检查 player_stats.deck/discard 集合操作 ==========
echo "[scene_nested_state_write] 4. 检查 player_stats.deck/discard 集合操作..."

# run_state.player_stats.(deck|discard|exhausted|consumables).(append|erase|clear|push_|pop_|insert|remove)
PLAYER_DECK_PATTERN='run_state\.player_stats\.(deck|discard|draw_pile|exhausted|consumables)\.(append|erase|clear|push_|pop_|insert|remove)\('
if has_matches "$PLAYER_DECK_PATTERN" "$SCENES_DIR"; then
  report_matches "$PLAYER_DECK_PATTERN" "$SCENES_DIR"
  fail "发现 run_state.player_stats.deck/discard 禁止的集合操作"
fi
pass "无 run_state.player_stats.deck/discard 禁止的集合操作"

# ========== 总结 ==========
echo ""
echo "[scene_nested_state_write] all checks passed."
echo "[scene_nested_state_write] 场景层未发现直接写入嵌套状态的操作。"
