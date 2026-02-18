#!/usr/bin/env bash
# run_flow_regression_check.sh - run_flow 非战斗分支契约门禁
# 目的：强制 rest/shop/event 分支统一使用 route_dispatcher.make_result 构造返回
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
	echo "  pattern: $pattern" >&2
	echo "  file: $file" >&2
	fail "$label"
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

ROUTE_FILE="runtime/modules/run_flow/route_dispatcher.gd"
REST_FLOW_FILE="runtime/modules/run_flow/rest_flow_service.gd"
SHOP_FLOW_FILE="runtime/modules/run_flow/shop_flow_service.gd"
EVENT_FLOW_FILE="runtime/modules/run_flow/event_flow_service.gd"

echo "[run_flow_regression] checking run_flow non-battle branch contracts..."

for file in "$ROUTE_FILE" "$REST_FLOW_FILE" "$SHOP_FLOW_FILE" "$EVENT_FLOW_FILE"; do
	[[ -f "$file" ]] || fail "missing required file: $file"
done
pass "all target files exist"

echo "[run_flow_regression] 1. route constants..."
assert_has 'const ROUTE_REST :=' "$ROUTE_FILE" "ROUTE_REST exists"
assert_has 'const ROUTE_SHOP :=' "$ROUTE_FILE" "ROUTE_SHOP exists"
assert_has 'const ROUTE_EVENT :=' "$ROUTE_FILE" "ROUTE_EVENT exists"
assert_has 'const ROUTE_MAP :=' "$ROUTE_FILE" "ROUTE_MAP exists"

echo "[run_flow_regression] 2. rest flow contract..."
assert_has 'func execute_rest\(.*\) -> Dictionary' "$REST_FLOW_FILE" "execute_rest returns Dictionary"
assert_has 'func execute_upgrade\(.*\) -> Dictionary' "$REST_FLOW_FILE" "execute_upgrade returns Dictionary"
assert_has 'func _result\(' "$REST_FLOW_FILE" "rest_flow has _result helper"
assert_has 'route_dispatcher\.make_result\(' "$REST_FLOW_FILE" "rest_flow _result uses route_dispatcher.make_result"
assert_not_has 'return \{' "$REST_FLOW_FILE" "rest_flow has no direct handcrafted return dictionaries"
assert_has '"completed":' "$REST_FLOW_FILE" "rest_flow payload includes completed"
assert_has '"info_text":' "$REST_FLOW_FILE" "rest_flow payload includes info_text"

echo "[run_flow_regression] 3. shop flow contract..."
assert_has 'func execute_buy_offer\(.*\) -> Dictionary' "$SHOP_FLOW_FILE" "execute_buy_offer returns Dictionary"
assert_has 'func execute_remove_card\(.*\) -> Dictionary' "$SHOP_FLOW_FILE" "execute_remove_card returns Dictionary"
assert_has 'func execute_leave\(.*\) -> Dictionary' "$SHOP_FLOW_FILE" "execute_leave returns Dictionary"
assert_has 'func _result\(' "$SHOP_FLOW_FILE" "shop_flow has _result helper"
assert_has 'route_dispatcher\.make_result\(' "$SHOP_FLOW_FILE" "shop_flow _result uses route_dispatcher.make_result"
assert_not_has 'return \{' "$SHOP_FLOW_FILE" "shop_flow has no direct handcrafted return dictionaries"
assert_has '"handled":' "$SHOP_FLOW_FILE" "shop_flow payload includes handled"
assert_has '"status_text":' "$SHOP_FLOW_FILE" "shop_flow payload includes status_text"

echo "[run_flow_regression] 4. event flow contract..."
assert_has 'func execute_option\(.*\) -> Dictionary' "$EVENT_FLOW_FILE" "execute_option returns Dictionary"
assert_has 'func execute_continue\(.*\) -> Dictionary' "$EVENT_FLOW_FILE" "execute_continue returns Dictionary"
assert_has 'func _result\(' "$EVENT_FLOW_FILE" "event_flow has _result helper"
assert_has 'route_dispatcher\.make_result\(' "$EVENT_FLOW_FILE" "event_flow _result uses route_dispatcher.make_result"
assert_not_has 'return \{' "$EVENT_FLOW_FILE" "event_flow has no direct handcrafted return dictionaries"
assert_has '"handled":' "$EVENT_FLOW_FILE" "event_flow payload includes handled"
assert_has '"result_text":' "$EVENT_FLOW_FILE" "event_flow payload includes result_text"
assert_has '"completed":' "$EVENT_FLOW_FILE" "event_flow payload includes completed"

echo ""
echo "[run_flow_regression] all checks passed."
