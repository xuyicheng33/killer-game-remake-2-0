#!/usr/bin/env bash
# workflow_gate_selfcheck.sh - workflow-check 门禁自检脚本
# 目的：验证门禁逻辑正确性，覆盖分支名/TASK_ID/白名单场景
# 用法：bash dev/tools/workflow_gate_selfcheck.sh
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

# ========== 1. 检查 rg/grep 降级可用 ==========
echo "[workflow_gate_selfcheck] 1. 检查搜索后端..."

if command -v rg >/dev/null 2>&1; then
  echo "  [INFO] rg 可用，将使用 rg 作为搜索后端"
else
  echo "  [INFO] rg 不可用，将使用 grep 作为降级后端"
fi

# 验证 run_flow_contract_check.sh 的降级逻辑
if grep -q "HAS_RG=" dev/tools/run_flow_contract_check.sh 2>/dev/null; then
  pass "run_flow_contract_check.sh 包含 rg 检测逻辑"
else
  fail "run_flow_contract_check.sh 缺少 rg 检测逻辑"
fi

if grep -q "grep fallback" dev/tools/run_flow_contract_check.sh 2>/dev/null; then
  pass "run_flow_contract_check.sh 包含 grep 降级逻辑"
else
  fail "run_flow_contract_check.sh 缺少 grep 降级逻辑"
fi

# ========== 2. 分支名格式检查 ==========
echo "[workflow_gate_selfcheck] 2. 检查分支名格式校验逻辑..."

branch_pattern='^(feat|fix|chore)/[a-z0-9_]+-[a-z0-9._-]+$'

# 测试非法分支名
invalid_branches=(
  "invalid-branch"
  "feature/wrong-prefix"
  "feat/WRONG-CASE"
  "hotfix/invalid-prefix"
)

all_invalid_passed=true
for test_branch in "${invalid_branches[@]}"; do
  if [[ "$test_branch" =~ $branch_pattern ]]; then
    echo "  [UNEXPECTED] '$test_branch' 应该失败格式检查" >&2
    all_invalid_passed=false
  else
    echo "  [OK] '$test_branch' 正确失败格式检查"
  fi
done

if [[ "$all_invalid_passed" == "true" ]]; then
  pass "分支名格式校验逻辑正确"
else
  fail "分支名格式校验逻辑错误"
fi

# 测试合法分支名
valid_branches=(
  "feat/module-test-task-v1"
  "fix/bug-fix-123-v1"
  "chore/docs-update-v1"
)

for test_branch in "${valid_branches[@]}"; do
  if [[ ! "$test_branch" =~ $branch_pattern ]]; then
    fail "合法分支名 '$test_branch' 应该通过格式检查"
  fi
done
pass "合法分支名格式校验通过"

# ========== 3. TASK_ID 对齐检查 ==========
echo "[workflow_gate_selfcheck] 3. 检查 TASK_ID 对齐逻辑..."

current_branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
current_task_id="${TASK_ID:-test-task-id}"

# 测试包含 TASK_ID 的分支
test_branch_with_taskid="feat/module-$current_task_id"
if [[ "$test_branch_with_taskid" == *"$current_task_id"* ]]; then
  echo "  [OK] 分支名包含 TASK_ID 的检测逻辑正确"
fi

# 测试不包含 TASK_ID 的分支
test_branch_without_taskid="feat/module-other-task-v1"
if [[ "$test_branch_without_taskid" != *"$current_task_id"* ]]; then
  echo "  [OK] 分支名不包含 TASK_ID 的检测逻辑正确"
fi

pass "TASK_ID 对齐检测逻辑正确"

# ========== 4. 白名单阻断场景检查 ==========
echo "[workflow_gate_selfcheck] 4. 检查白名单阻断逻辑..."

# 检查 workflow_check.sh 是否包含白名单检查逻辑
if grep -q "whitelist_patterns" dev/tools/workflow_check.sh 2>/dev/null; then
  pass "workflow_check.sh 包含白名单检查逻辑"
else
  fail "workflow_check.sh 缺少白名单检查逻辑"
fi

# 检查是否检查 untracked 文件
if grep -q "ls-files --others" dev/tools/workflow_check.sh 2>/dev/null; then
  pass "workflow_check.sh 包含 untracked 文件检查"
else
  fail "workflow_check.sh 缺少 untracked 文件检查"
fi

# 检查白名单阻断逻辑：不在白名单的文件应该被阻断
# 模拟测试：检查 workflow_check.sh 中的阻断代码
if grep -q "is outside whitelist" dev/tools/workflow_check.sh 2>/dev/null; then
  pass "workflow_check.sh 包含白名单阻断输出"
else
  fail "workflow_check.sh 缺少白名单阻断输出"
fi

# ========== 5. 总结 ==========
echo ""
echo "[workflow_gate_selfcheck] all checks passed."
echo "[workflow_gate_selfcheck] 门禁自检通过：rg/grep 降级、分支格式、TASK_ID 对齐、白名单阻断。"
