#!/usr/bin/env bash
# run_flow_payload_contract_check.sh - run_flow payload 契约门禁
# 目的：防止路由返回结构被悄悄改坏
# 用法：bash dev/tools/run_flow_payload_contract_check.sh
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

# 检查是否有匹配
has_match() {
  local pattern="$1"
  local file="$2"
  if grep -qE "$pattern" "$file" 2>/dev/null; then
    return 0
  fi
  return 1
}

# 报告匹配的文件和行号
report_match() {
  local pattern="$1"
  local file="$2"
  echo "  [context] pattern: $pattern" >&2
  echo "  [context] file: $file" >&2
  grep -nE "$pattern" "$file" 2>/dev/null | head -5 >&2 || true
}

ROUTE_FILE="runtime/modules/run_flow/route_dispatcher.gd"
MAP_FLOW_FILE="runtime/modules/run_flow/map_flow_service.gd"
BATTLE_FLOW_FILE="runtime/modules/run_flow/battle_flow_service.gd"

echo "[run_flow_payload_contract] checking run_flow payload contracts..."

# ========== 1. 检查 make_result 函数签名与返回结构 ==========
echo "[run_flow_payload_contract] 1. 检查 make_result 函数签名与返回结构..."

# make_result 必须接受 next_route 和 payload 参数
MAKE_RESULT_SIG='func make_result\(next_route: String, payload: Dictionary = \{\}\) -> Dictionary:'
if ! has_match "$MAKE_RESULT_SIG" "$ROUTE_FILE"; then
  report_match "$MAKE_RESULT_SIG" "$ROUTE_FILE"
  fail "make_result 函数签名不符合契约"
fi
pass "make_result 函数签名正确"

# make_result 必须返回包含 next_route 的字典
MAKE_RESULT_RETURN='"next_route": next_route'
if ! has_match "$MAKE_RESULT_RETURN" "$ROUTE_FILE"; then
  report_match "$MAKE_RESULT_RETURN" "$ROUTE_FILE"
  fail "make_result 返回必须包含 next_route"
fi
pass "make_result 返回包含 next_route"

# make_result 必须将 payload 合并到返回字典
MAKE_RESULT_PAYLOAD_LOOP='for key in payload\.keys\(\):'
if ! has_match "$MAKE_RESULT_PAYLOAD_LOOP" "$ROUTE_FILE"; then
  report_match "$MAKE_RESULT_PAYLOAD_LOOP" "$ROUTE_FILE"
  fail "make_result 必须遍历 payload 字段"
fi
pass "make_result 遍历 payload 字段"

MAKE_RESULT_PAYLOAD_ASSIGN='out\[key\] = payload\[key\]'
if ! has_match "$MAKE_RESULT_PAYLOAD_ASSIGN" "$ROUTE_FILE"; then
  report_match "$MAKE_RESULT_PAYLOAD_ASSIGN" "$ROUTE_FILE"
  fail "make_result 必须合并 payload 字段到返回结果"
fi
pass "make_result 合并 payload 字段"

# ========== 2. 检查 map_flow enter_map_node payload ==========
echo "[run_flow_payload_contract] 2. 检查 map_flow enter_map_node payload..."

# enter_map_node 必须返回包含 accepted 字段
ENTER_ACCEPTED='"accepted": (true|false)'
if ! has_match "$ENTER_ACCEPTED" "$MAP_FLOW_FILE"; then
  report_match "$ENTER_ACCEPTED" "$MAP_FLOW_FILE"
  fail "enter_map_node 返回必须包含 accepted"
fi
pass "enter_map_node 返回包含 accepted"

# enter_map_node 成功时必须包含 node_id
ENTER_NODE_ID='"node_id": node\.id'
if ! has_match "$ENTER_NODE_ID" "$MAP_FLOW_FILE"; then
  report_match "$ENTER_NODE_ID" "$MAP_FLOW_FILE"
  fail "enter_map_node 成功时必须包含 node_id"
fi
pass "enter_map_node 成功时包含 node_id"

# enter_map_node 成功时必须包含 node_type
ENTER_NODE_TYPE='"node_type": node\.type'
if ! has_match "$ENTER_NODE_TYPE" "$MAP_FLOW_FILE"; then
  report_match "$ENTER_NODE_TYPE" "$MAP_FLOW_FILE"
  fail "enter_map_node 成功时必须包含 node_type"
fi
pass "enter_map_node 成功时包含 node_type"

# enter_map_node 成功时必须包含 reward_gold
ENTER_REWARD_GOLD='"reward_gold": node\.reward_gold'
if ! has_match "$ENTER_REWARD_GOLD" "$MAP_FLOW_FILE"; then
  report_match "$ENTER_REWARD_GOLD" "$MAP_FLOW_FILE"
  fail "enter_map_node 成功时必须包含 reward_gold"
fi
pass "enter_map_node 成功时包含 reward_gold"

# ========== 3. 检查 map_flow resolve_non_battle_completion payload ==========
echo "[run_flow_payload_contract] 3. 检查 map_flow resolve_non_battle_completion payload..."

# resolve_non_battle_completion 必须返回包含 node_type
NON_BATTLE_NODE_TYPE='"node_type": node_type'
if ! has_match "$NON_BATTLE_NODE_TYPE" "$MAP_FLOW_FILE"; then
  report_match "$NON_BATTLE_NODE_TYPE" "$MAP_FLOW_FILE"
  fail "resolve_non_battle_completion 返回必须包含 node_type"
fi
pass "resolve_non_battle_completion 返回包含 node_type"

# resolve_non_battle_completion 必须返回包含 bonus_log
NON_BATTLE_BONUS_LOG='"bonus_log": bonus_log'
if ! has_match "$NON_BATTLE_BONUS_LOG" "$MAP_FLOW_FILE"; then
  report_match "$NON_BATTLE_BONUS_LOG" "$MAP_FLOW_FILE"
  fail "resolve_non_battle_completion 返回必须包含 bonus_log"
fi
pass "resolve_non_battle_completion 返回包含 bonus_log"

# ========== 4. 检查 battle_flow resolve_battle_completion payload ==========
echo "[run_flow_payload_contract] 4. 检查 battle_flow resolve_battle_completion payload..."

# battle win 必须返回包含 reward_gold
BATTLE_WIN_REWARD='"reward_gold": maxi\(0, reward_gold\)'
if ! has_match "$BATTLE_WIN_REWARD" "$BATTLE_FLOW_FILE"; then
  report_match "$BATTLE_WIN_REWARD" "$BATTLE_FLOW_FILE"
  fail "battle win 返回必须包含 reward_gold"
fi
pass "battle win 返回包含 reward_gold"

# battle lose 必须返回包含 game_over_text
BATTLE_LOSE_TEXT='"game_over_text": _build_game_over_text\(run_state\)'
if ! has_match "$BATTLE_LOSE_TEXT" "$BATTLE_FLOW_FILE"; then
  report_match "$BATTLE_LOSE_TEXT" "$BATTLE_FLOW_FILE"
  fail "battle lose 返回必须包含 game_over_text"
fi
pass "battle lose 返回包含 game_over_text"

# ========== 5. 检查 battle_flow apply_battle_reward payload ==========
echo "[run_flow_payload_contract] 5. 检查 battle_flow apply_battle_reward payload..."

# reward apply 必须返回包含 reward_log
REWARD_APPLY_LOG='"reward_log": reward_log'
if ! has_match "$REWARD_APPLY_LOG" "$BATTLE_FLOW_FILE"; then
  report_match "$REWARD_APPLY_LOG" "$BATTLE_FLOW_FILE"
  fail "reward apply 返回必须包含 reward_log"
fi
pass "reward apply 返回包含 reward_log"

# ========== 6. 检查所有返回必须通过 make_result 构造 ==========
echo "[run_flow_payload_contract] 6. 检查返回构造通过 make_result..."

# map_flow 必须调用 route_dispatcher.make_result
MAP_FLOW_MAKE_RESULT='route_dispatcher\.make_result\('
if ! has_match "$MAP_FLOW_MAKE_RESULT" "$MAP_FLOW_FILE"; then
  report_match "$MAP_FLOW_MAKE_RESULT" "$MAP_FLOW_FILE"
  fail "map_flow 必须通过 route_dispatcher.make_result 构造返回"
fi
pass "map_flow 通过 make_result 构造返回"

# battle_flow 必须调用 route_dispatcher.make_result (通过 _result)
BATTLE_FLOW_MAKE_RESULT='route_dispatcher\.make_result\('
if ! has_match "$BATTLE_FLOW_MAKE_RESULT" "$BATTLE_FLOW_FILE"; then
  report_match "$BATTLE_FLOW_MAKE_RESULT" "$BATTLE_FLOW_FILE"
  fail "battle_flow 必须通过 route_dispatcher.make_result 构造返回"
fi
pass "battle_flow 通过 make_result 构造返回"

# ========== 总结 ==========
echo ""
echo "[run_flow_payload_contract] all checks passed."
echo "[run_flow_payload_contract] run_flow payload 契约完整。"
