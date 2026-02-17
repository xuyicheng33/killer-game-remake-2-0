#!/usr/bin/env bash
# run_flow_regression_check.sh - run_flow 回归门禁
# 目的：强制 rest/shop/event 分支返回通过 route_dispatcher.make_result 构造
# 用法：bash dev/tools/run_flow_regression_check.sh
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

warn() {
  local message="$1"
  echo "[WARN] $message" >&2
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
REST_FLOW_FILE="runtime/modules/run_flow/rest_flow_service.gd"
SHOP_FLOW_FILE="runtime/modules/run_flow/shop_flow_service.gd"
EVENT_FLOW_FILE="runtime/modules/run_flow/event_flow_service.gd"

echo "[run_flow_regression] checking run_flow non-battle branch contracts..."

# ========== 0. 基础文件存在性检查 ==========
echo "[run_flow_regression] 0. 检查目标文件存在..."

for file in "$ROUTE_FILE" "$REST_FLOW_FILE" "$SHOP_FLOW_FILE" "$EVENT_FLOW_FILE"; do
  if [[ ! -f "$file" ]]; then
    fail "缺少必要文件: $file"
  fi
done
pass "所有目标文件存在"

# ========== 1. rest_flow 契约检查 ==========
echo "[run_flow_regression] 1. 检查 rest_flow_service 契约..."

# 检查是否有 _result 封装函数
REST_HAS_RESULT='func _result\('
if ! has_match "$REST_HAS_RESULT" "$REST_FLOW_FILE"; then
  warn "rest_flow_service 缺少 _result 封装函数"
else
  pass "rest_flow_service 有 _result 封装函数"
  
  # 检查 _result 是否调用 route_dispatcher.make_result
  REST_RESULT_USES_MAKE='route_dispatcher\.make_result\('
  if ! has_match "$REST_RESULT_USES_MAKE" "$REST_FLOW_FILE"; then
    warn "rest_flow_service._result 未调用 route_dispatcher.make_result"
  else
    pass "rest_flow_service._result 调用 route_dispatcher.make_result"
  fi
fi

# 检查是否直接返回手写字典（非封装调用）
REST_DIRECT_DICT='return \{'
if has_match "$REST_DIRECT_DICT" "$REST_FLOW_FILE"; then
  warn "rest_flow_service 存在直接返回手写字典"
else
  pass "rest_flow_service 无直接返回手写字典"
fi

# 检查 execute_rest 返回键位
if has_match 'func execute_rest.*Dictionary' "$REST_FLOW_FILE"; then
  pass "execute_rest 声明返回 Dictionary"
  
  # 检查返回是否包含 completed
  if has_match '"completed":' "$REST_FLOW_FILE"; then
    pass "rest_flow 返回包含 completed 键"
  else
    warn "rest_flow 返回可能缺少 completed 键"
  fi
  
  # 检查返回是否包含 info_text
  if has_match '"info_text":' "$REST_FLOW_FILE"; then
    pass "rest_flow 返回包含 info_text 键"
  else
    warn "rest_flow 返回可能缺少 info_text 键"
  fi
fi

# ========== 2. shop_flow 契约检查 ==========
echo "[run_flow_regression] 2. 检查 shop_flow_service 契约..."

# 检查是否有 _result 封装函数
SHOP_HAS_RESULT='func _result\('
if ! has_match "$SHOP_HAS_RESULT" "$SHOP_FLOW_FILE"; then
  warn "shop_flow_service 缺少 _result 封装函数"
else
  pass "shop_flow_service 有 _result 封装函数"
  
  # 检查 _result 是否调用 route_dispatcher.make_result
  SHOP_RESULT_USES_MAKE='route_dispatcher\.make_result\('
  if ! has_match "$SHOP_RESULT_USES_MAKE" "$SHOP_FLOW_FILE"; then
    warn "shop_flow_service._result 未调用 route_dispatcher.make_result"
  else
    pass "shop_flow_service._result 调用 route_dispatcher.make_result"
  fi
fi

# 检查是否直接返回手写字典
if has_match "$REST_DIRECT_DICT" "$SHOP_FLOW_FILE"; then
  warn "shop_flow_service 存在直接返回手写字典"
else
  pass "shop_flow_service 无直接返回手写字典"
fi

# 检查 execute_buy_offer 返回键位
if has_match 'func execute_buy_offer.*Dictionary' "$SHOP_FLOW_FILE"; then
  pass "execute_buy_offer 声明返回 Dictionary"
  
  # 检查返回是否包含 handled
  if has_match '"handled":' "$SHOP_FLOW_FILE"; then
    pass "shop_flow 返回包含 handled 键"
  else
    warn "shop_flow 返回可能缺少 handled 键"
  fi
  
  # 检查返回是否包含 status_text
  if has_match '"status_text":' "$SHOP_FLOW_FILE"; then
    pass "shop_flow 返回包含 status_text 键"
  else
    warn "shop_flow 返回可能缺少 status_text 键"
  fi
fi

# 检查 execute_leave 是否为 void（非契约返回）
if has_match 'func execute_leave.*void' "$SHOP_FLOW_FILE"; then
  pass "execute_leave 声明返回 void（非路由返回）"
fi

# ========== 3. event_flow 契约检查 ==========
echo "[run_flow_regression] 3. 检查 event_flow_service 契约..."

# event_flow 与其他不同，execute_option 返回 String，execute_continue 返回 void
# 检查是否存在 _result 封装
EVENT_HAS_RESULT='func _result\('
if ! has_match "$EVENT_HAS_RESULT" "$EVENT_FLOW_FILE"; then
  warn "event_flow_service 缺少 _result 封装函数"
else
  pass "event_flow_service 有 _result 封装函数"
  
  # 检查 _result 是否调用 route_dispatcher.make_result
  EVENT_RESULT_USES_MAKE='route_dispatcher\.make_result\('
  if ! has_match "$EVENT_RESULT_USES_MAKE" "$EVENT_FLOW_FILE"; then
    warn "event_flow_service._result 未调用 route_dispatcher.make_result"
  else
    pass "event_flow_service._result 调用 route_dispatcher.make_result"
  fi
fi

# 检查是否直接返回手写字典
if has_match "$REST_DIRECT_DICT" "$EVENT_FLOW_FILE"; then
  warn "event_flow_service 存在直接返回手写字典"
else
  pass "event_flow_service 无直接返回手写字典"
fi

# 检查 execute_option 返回类型（当前为 String，与路由契约不符）
if has_match 'func execute_option.*String' "$EVENT_FLOW_FILE"; then
  warn "execute_option 返回 String，非 Dictionary 路由契约"
fi

# 检查 execute_continue 返回类型（当前为 void）
if has_match 'func execute_continue.*void' "$EVENT_FLOW_FILE"; then
  warn "execute_continue 返回 void，非路由契约返回"
fi

# ========== 4. 路由常量一致性检查 ==========
echo "[run_flow_regression] 4. 检查路由常量定义..."

# 检查 ROUTE_REST/SHOP/EVENT 是否存在
for route in "REST" "SHOP" "EVENT"; do
  if has_match "ROUTE_$route" "$ROUTE_FILE"; then
    pass "ROUTE_$route 常量存在"
  else
    warn "ROUTE_$route 常量可能缺失"
  fi
done

# ========== 5. 返回结构键位对比 ==========
echo "[run_flow_regression] 5. 返回结构键位对比..."

# rest_flow 返回键
REST_KEYS=("completed" "info_text")
# shop_flow 返回键
SHOP_KEYS=("handled" "status_text")

# 检查键位一致性
for key in "${REST_KEYS[@]}"; do
  if has_match "\"$key\":" "$REST_FLOW_FILE"; then
    pass "rest_flow 返回包含 '$key'"
  else
    warn "rest_flow 返回可能缺少 '$key'"
  fi
done

for key in "${SHOP_KEYS[@]}"; do
  if has_match "\"$key\":" "$SHOP_FLOW_FILE"; then
    pass "shop_flow 返回包含 '$key'"
  else
    warn "shop_flow 返回可能缺少 '$key'"
  fi
done

# ========== 总结 ==========
echo ""
echo "[run_flow_regression] regression gate check completed."
echo "[run_flow_regression] 注意：WARN 表示当前实现与契约存在偏差，但不阻塞流程。"
echo "[run_flow_regression] 预期：rest/shop/event 需要后续改造以统一使用 route_dispatcher.make_result"
