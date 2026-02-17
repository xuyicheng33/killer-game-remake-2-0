#!/usr/bin/env bash
# run_flow_result_shape_check.sh - run_flow 结果结构统一门禁
# 目的：强制 run_flow 服务返回的字典通过统一 helper 构造，减少键漂移
# 用法：bash dev/tools/run_flow_result_shape_check.sh
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

echo "[run_flow_result_shape] checking run_flow result shape contracts..."

# ========== 1. 检查 route_dispatcher.make_result 存在 ==========
echo "[run_flow_result_shape] 1. 检查 route_dispatcher.make_result 存在..."

MAKE_RESULT_FUNC='func make_result\(next_route: String, payload: Dictionary = \{\}\) -> Dictionary:'
if ! has_match "$MAKE_RESULT_FUNC" "$ROUTE_FILE"; then
  report_match "$MAKE_RESULT_FUNC" "$ROUTE_FILE"
  fail "route_dispatcher.make_result 函数不存在或签名不符"
fi
pass "route_dispatcher.make_result 函数存在且签名正确"

# ========== 2. 检查 make_result 返回包含 next_route ==========
echo "[run_flow_result_shape] 2. 检查 make_result 返回包含 next_route..."

MAKE_RESULT_RETURN='"next_route": next_route'
if ! has_match "$MAKE_RESULT_RETURN" "$ROUTE_FILE"; then
  report_match "$MAKE_RESULT_RETURN" "$ROUTE_FILE"
  fail "make_result 返回必须包含 next_route"
fi
pass "make_result 返回包含 next_route"

# ========== 3. 检查 map_flow 所有返回通过 make_result ==========
echo "[run_flow_result_shape] 3. 检查 map_flow 所有返回通过 make_result..."

# map_flow 必须使用 route_dispatcher.make_result 进行返回
MAP_FLOW_MAKE_RESULT='return route_dispatcher\.make_result\('
if ! has_match "$MAP_FLOW_MAKE_RESULT" "$MAP_FLOW_FILE"; then
  report_match "$MAP_FLOW_MAKE_RESULT" "$MAP_FLOW_FILE"
  fail "map_flow 必须通过 route_dispatcher.make_result 构造返回"
fi
pass "map_flow 通过 make_result 构造返回"

# ========== 4. 检查 battle_flow 所有返回通过 _result ==========
echo "[run_flow_result_shape] 4. 检查 battle_flow 所有返回通过 _result..."

# battle_flow 必须使用 _result 进行返回
BATTLE_FLOW_RESULT='return _result\('
if ! has_match "$BATTLE_FLOW_RESULT" "$BATTLE_FLOW_FILE"; then
  report_match "$BATTLE_FLOW_RESULT" "$BATTLE_FLOW_FILE"
  fail "battle_flow 必须通过 _result 构造返回"
fi
pass "battle_flow 通过 _result 构造返回"

# ========== 5. 检查 battle_flow._result 调用 make_result ==========
echo "[run_flow_result_shape] 5. 检查 battle_flow._result 调用 make_result..."

# _result 函数签名必须正确
BATTLE_FLOW_RESULT_SIG='func _result\(next_route: String, payload: Dictionary = \{\}\) -> Dictionary:'
if ! has_match "$BATTLE_FLOW_RESULT_SIG" "$BATTLE_FLOW_FILE"; then
  report_match "$BATTLE_FLOW_RESULT_SIG" "$BATTLE_FLOW_FILE"
  fail "battle_flow._result 函数签名不正确"
fi
pass "battle_flow._result 函数签名正确"

# _result 函数体内必须调用 route_dispatcher.make_result
BATTLE_FLOW_RESULT_BODY='return route_dispatcher\.make_result\(next_route, payload\)'
if ! has_match "$BATTLE_FLOW_RESULT_BODY" "$BATTLE_FLOW_FILE"; then
  report_match "$BATTLE_FLOW_RESULT_BODY" "$BATTLE_FLOW_FILE"
  fail "battle_flow._result 必须调用 route_dispatcher.make_result"
fi
pass "battle_flow._result 调用 make_result"

# ========== 6. 禁止 map_flow 直接返回手写字典 ==========
echo "[run_flow_result_shape] 6. 禁止 map_flow 直接返回手写字典..."

# 禁止 return { ... } 模式（手写字典）
DIRECT_DICT_RETURN='return \{'
if has_match "$DIRECT_DICT_RETURN" "$MAP_FLOW_FILE"; then
  echo "  [context] 发现 map_flow 直接返回手写字典:" >&2
  grep -nE "$DIRECT_DICT_RETURN" "$MAP_FLOW_FILE" 2>/dev/null | head -5 >&2 || true
  fail "map_flow 禁止直接返回手写字典，必须使用 route_dispatcher.make_result"
fi
pass "map_flow 无直接返回手写字典"

# ========== 7. 禁止 battle_flow 直接返回手写字典 ==========
echo "[run_flow_result_shape] 7. 禁止 battle_flow 直接返回手写字典..."

if has_match "$DIRECT_DICT_RETURN" "$BATTLE_FLOW_FILE"; then
  echo "  [context] 发现 battle_flow 直接返回手写字典:" >&2
  grep -nE "$DIRECT_DICT_RETURN" "$BATTLE_FLOW_FILE" 2>/dev/null | head -5 >&2 || true
  fail "battle_flow 禁止直接返回手写字典，必须使用 _result"
fi
pass "battle_flow 无直接返回手写字典"

# ========== 8. 禁止直接包含 next_route 的手写字典 ==========
echo "[run_flow_result_shape] 8. 禁止直接包含 next_route 的手写字典..."

# 禁止 return { ... "next_route": ... } 模式
DIRECT_NEXT_ROUTE='return \{[^}]*"next_route"'
if has_match "$DIRECT_NEXT_ROUTE" "$MAP_FLOW_FILE"; then
  echo "  [context] 发现 map_flow 直接返回包含 next_route 的字典:" >&2
  grep -nE "$DIRECT_NEXT_ROUTE" "$MAP_FLOW_FILE" 2>/dev/null | head -5 >&2 || true
  fail "map_flow 禁止直接返回包含 next_route 的字典"
fi
pass "map_flow 无直接返回 next_route 字典"

if has_match "$DIRECT_NEXT_ROUTE" "$BATTLE_FLOW_FILE"; then
  echo "  [context] 发现 battle_flow 直接返回包含 next_route 的字典:" >&2
  grep -nE "$DIRECT_NEXT_ROUTE" "$BATTLE_FLOW_FILE" 2>/dev/null | head -5 >&2 || true
  fail "battle_flow 禁止直接返回包含 next_route 的字典"
fi
pass "battle_flow 无直接返回 next_route 字典"

# ========== 总结 ==========
echo ""
echo "[run_flow_result_shape] all checks passed."
echo "[run_flow_result_shape] run_flow 结果结构统一，所有返回通过 helper 构造。"
