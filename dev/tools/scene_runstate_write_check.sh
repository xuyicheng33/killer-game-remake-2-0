#!/usr/bin/env bash
# scene_runstate_write_check.sh - 场景层禁止直接写 RunState 门禁
# 目的：防止后续回归把状态写入散落回 scenes
# 用法：bash dev/tools/scene_runstate_write_check.sh
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
  echo "  [context] forbidden writes found:" >&2
  grep -rnE "$pattern" "$path" 2>/dev/null | head -20 >&2 || true
}

SCENES_DIR="runtime/scenes"

echo "[scene_runstate_write] checking forbidden run_state write patterns in runtime/scenes..."

# ========== 1. 检查赋值操作 ==========
echo "[scene_runstate_write] 1. 检查直接赋值操作..."

# run_state.<field> = (但不匹配 == 和 !=)
ASSIGN_PATTERN='run_state\.\w+\s*=(?!=)'
if has_matches "$ASSIGN_PATTERN" "$SCENES_DIR"; then
  report_matches "$ASSIGN_PATTERN" "$SCENES_DIR"
  fail "发现 run_state 直接赋值操作"
fi
pass "无 run_state 直接赋值操作"

# ========== 2. 检查复合赋值操作 ==========
echo "[scene_runstate_write] 2. 检查复合赋值操作 (+=, -=, *=, /=, %=)..."

COMPOUND_PATTERN='run_state\.\w+\s*(\+|\-|\*|\/|\%)='
if has_matches "$COMPOUND_PATTERN" "$SCENES_DIR"; then
  report_matches "$COMPOUND_PATTERN" "$SCENES_DIR"
  fail "发现 run_state 复合赋值操作"
fi
pass "无 run_state 复合赋值操作"

# ========== 3. 检查集合修改操作 ==========
echo "[scene_runstate_write] 3. 检查集合修改操作 (append/erase/clear/push/pop)..."

COLLECTION_PATTERN='run_state\.\w+\.(append|erase|clear|push_(back|front)|pop_(back|front)|insert|remove)\('
if has_matches "$COLLECTION_PATTERN" "$SCENES_DIR"; then
  report_matches "$COLLECTION_PATTERN" "$SCENES_DIR"
  fail "发现 run_state 集合修改操作"
fi
pass "无 run_state 集合修改操作"

# ========== 4. 检查 set_/add_/remove_/clear_/advance_/mark_/apply_ 方法调用 ==========
echo "[scene_runstate_write] 4. 检查禁止的方法调用 (set_/add_/remove_/clear_/advance_/mark_/apply_)..."

METHOD_PATTERN='run_state\.(set_|add_|remove_|clear_|advance_|mark_|apply_)\w*\('
if has_matches "$METHOD_PATTERN" "$SCENES_DIR"; then
  report_matches "$METHOD_PATTERN" "$SCENES_DIR"
  fail "发现 run_state 禁止的方法调用"
fi
pass "无 run_state 禁止的方法调用"

# ========== 5. 检查 player_stats 写入（嵌套访问）==========
echo "[scene_runstate_write] 5. 检查 player_stats 嵌套写入..."

# run_state.player_stats.<field> = (赋值)
PLAYER_STATS_ASSIGN='run_state\.player_stats\.\w+\s*=(?!=)'
if has_matches "$PLAYER_STATS_ASSIGN" "$SCENES_DIR"; then
  report_matches "$PLAYER_STATS_ASSIGN" "$SCENES_DIR"
  fail "发现 run_state.player_stats 直接赋值操作"
fi
pass "无 run_state.player_stats 直接赋值操作"

# run_state.player_stats.<field> += 等
PLAYER_STATS_COMPOUND='run_state\.player_stats\.\w+\s*(\+|\-|\*|\/|\%)='
if has_matches "$PLAYER_STATS_COMPOUND" "$SCENES_DIR"; then
  report_matches "$PLAYER_STATS_COMPOUND" "$SCENES_DIR"
  fail "发现 run_state.player_stats 复合赋值操作"
fi
pass "无 run_state.player_stats 复合赋值操作"

# ========== 总结 ==========
echo ""
echo "[scene_runstate_write] all checks passed."
echo "[scene_runstate_write] 场景层未发现直接写入 RunState 的操作。"
