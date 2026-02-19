#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# 仅拦截高风险转换模式：Dictionary.get / load / get_child 直接 as。
# 安全白名单（不在本脚本拦截范围）：
# - .new() as ClassName
# - .instantiate() as ClassName
# - .duplicate(...) as ClassName
# - 已先做 typeof/is 判定的本地变量转换

read -r -d '' PATTERN <<'PATTERN' || true
\.get\([^\n]*\)\s+as\s+|\bload\([^\n]*\)\s+as\s+|\bget_child\([^\n]*\)\s+as\s+
PATTERN

if rg -n --pcre2 "$PATTERN" runtime content >/tmp/type_safety_violations.log 2>/dev/null; then
	echo "[type-safety-check] failed: found unsafe cast patterns:" >&2
	cat /tmp/type_safety_violations.log >&2
	exit 1
fi

echo "[type-safety-check] passed."
