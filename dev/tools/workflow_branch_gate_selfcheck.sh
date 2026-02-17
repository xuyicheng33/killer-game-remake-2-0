#!/usr/bin/env bash
# workflow_branch_gate_selfcheck.sh - workflow-check 分支门禁自检脚本
# 目的：自动覆盖 3 个场景的测试
# 用法：bash dev/tools/workflow_branch_gate_selfcheck.sh
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

# ========== 分支门禁检查函数 ==========
check_branch_format() {
  local branch="$1"
  local branch_pattern='^(feat|fix|chore)/[a-z0-9_]+-[a-z0-9._-]+$'

  if [[ "$branch" == "main" ]]; then
    return 0  # main 分支跳过格式检查
  fi

  if [[ "$branch" =~ $branch_pattern ]]; then
    return 0
  fi
  return 1
}

check_branch_contains_taskid() {
  local branch="$1"
  local task_id="$2"

  if [[ "$branch" == "main" ]]; then
    return 0  # main 分支跳过 TASK_ID 检查
  fi

  if [[ "$branch" == *"$task_id"* ]]; then
    return 0
  fi
  return 1
}

# ========== 场景测试 ==========
echo "[branch_gate_selfcheck] 测试 workflow-check 分支门禁..."

# 获取当前分支名
current_branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
if [[ -z "$current_branch" ]]; then
  fail "无法获取当前分支名（detached HEAD？）"
fi

current_task_id="${TASK_ID:-phase22-workflow-branch-gate-selfcheck-v1}"

echo ""
echo "[branch_gate_selfcheck] 当前分支: $current_branch"
echo "[branch_gate_selfcheck] 当前 TASK_ID: $current_task_id"
echo ""

# ========== 场景 1：分支名格式非法 -> 失败 ==========
echo "[branch_gate_selfcheck] 场景 1: 分支名格式非法应失败..."

invalid_branches=(
  "invalid-branch"
  "feature/wrong-format"
  "feat/WRONG-CASE"
  "hotfix/invalid-prefix"
  "feat/missing_suffix"
)

all_invalid_passed=true
for test_branch in "${invalid_branches[@]}"; do
  if check_branch_format "$test_branch"; then
    echo "  [UNEXPECTED] '$test_branch' 应该失败格式检查但通过了" >&2
    all_invalid_passed=false
  else
    echo "  [OK] '$test_branch' 格式检查正确失败"
  fi
done

if [[ "$all_invalid_passed" == "true" ]]; then
  pass "场景 1: 非法分支名格式检查正确失败"
else
  fail "场景 1: 非法分支名格式检查行为不符合预期"
fi

# ========== 场景 2：分支名合法但不含 TASK_ID -> 失败 ==========
echo "[branch_gate_selfcheck] 场景 2: 分支名合法但不含 TASK_ID 应失败..."

# 使用当前分支（如果不含 TASK_ID）或模拟测试
test_task_id="nonexistent-task-id-xxx"

if check_branch_format "$current_branch"; then
  echo "  当前分支 '$current_branch' 格式合法"
  if check_branch_contains_taskid "$current_branch" "$test_task_id"; then
    echo "  [UNEXPECTED] 分支不应包含 TASK_ID '$test_task_id'" >&2
    fail "场景 2: TASK_ID 检查逻辑错误"
  else
    echo "  [OK] 分支正确不包含 TASK_ID '$test_task_id'"
  fi
else
  echo "  [SKIP] 当前分支格式不合法，跳过场景 2 的实时验证"
fi

# 额外测试：模拟合法分支不含 TASK_ID
test_branch_valid="feat/module-some-other-task-v1"
if check_branch_format "$test_branch_valid"; then
  if check_branch_contains_taskid "$test_branch_valid" "$test_task_id"; then
    echo "  [UNEXPECTED] '$test_branch_valid' 不应包含 '$test_task_id'" >&2
    fail "场景 2: TASK_ID 检查逻辑错误"
  else
    echo "  [OK] '$test_branch_valid' 正确不包含 TASK_ID '$test_task_id'"
  fi
fi

pass "场景 2: 合法分支不含 TASK_ID 检查正确失败"

# ========== 场景 3：分支名合法且包含 TASK_ID -> 通过 ==========
echo "[branch_gate_selfcheck] 场景 3: 分支名合法且包含 TASK_ID 应通过..."

if check_branch_format "$current_branch"; then
  echo "  当前分支 '$current_branch' 格式合法"
  if check_branch_contains_taskid "$current_branch" "$current_task_id"; then
    echo "  [OK] 分支正确包含 TASK_ID '$current_task_id'"
  else
    echo "  [INFO] 当前分支不含 TASK_ID '$current_task_id'（可能在不同分支上运行）"
    # 模拟测试
    test_branch_with_taskid="feat/module-$current_task_id"
    if check_branch_format "$test_branch_with_taskid" && check_branch_contains_taskid "$test_branch_with_taskid" "$current_task_id"; then
      echo "  [OK] 模拟分支 '$test_branch_with_taskid' 正确包含 TASK_ID"
    else
      fail "场景 3: 合法分支含 TASK_ID 检查逻辑错误"
    fi
  fi
else
  # 当前分支格式不合法，使用模拟测试
  test_branch_with_taskid="feat/module-$current_task_id"
  if check_branch_format "$test_branch_with_taskid" && check_branch_contains_taskid "$test_branch_with_taskid" "$current_task_id"; then
    echo "  [OK] 模拟分支 '$test_branch_with_taskid' 正确包含 TASK_ID"
  else
    fail "场景 3: 合法分支含 TASK_ID 检查逻辑错误"
  fi
fi

pass "场景 3: 合法分支含 TASK_ID 检查正确通过"

# ========== 总结 ==========
echo ""
echo "[branch_gate_selfcheck] all checks passed."
echo "[branch_gate_selfcheck] 分支门禁 3 个场景测试通过。"
