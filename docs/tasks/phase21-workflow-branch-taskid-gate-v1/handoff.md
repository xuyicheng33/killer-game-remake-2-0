# Handoff: phase21-workflow-branch-taskid-gate-v1

## 交付清单

### 修改文件

| 文件 | 变更说明 |
|------|----------|
| `dev/tools/workflow_check.sh` | 新增分支名与 TASK_ID 一致性检查 |
| `docs/work_logs/2026-02.md` | 新增 Phase 21 工作日志 |

### 新增文件

| 文件 | 说明 |
|------|------|
| `docs/tasks/phase21-workflow-branch-taskid-gate-v1/plan.md` | 任务计划 |
| `docs/tasks/phase21-workflow-branch-taskid-gate-v1/handoff.md` | 本文件 |
| `docs/tasks/phase21-workflow-branch-taskid-gate-v1/verification.md` | 验证指南 |

## 变更详情

### workflow_check.sh 修改

**修改前**（第 53-57 行）：
```bash
branch_pattern='^(feat|fix|chore)/[a-z0-9_]+-[a-z0-9._-]+$'
if [[ "$branch" != "main" && ! "$branch" =~ $branch_pattern ]]; then
  echo "[workflow-check] failed: branch '$branch' does not match feat|fix|chore/<module>-<task-id>." >&2
  exit 1
fi
```

**修改后**：
```bash
branch_pattern='^(feat|fix|chore)/[a-z0-9_]+-[a-z0-9._-]+$'
if [[ "$branch" != "main" && ! "$branch" =~ $branch_pattern ]]; then
  echo "[workflow-check] failed: branch '$branch' does not match feat|fix|chore/<module>-<task-id>." >&2
  exit 1
fi

# 校验分支名包含 TASK_ID
if [[ "$branch" != "main" ]]; then
  if [[ "$branch" != *"$task_id"* ]]; then
    echo "[workflow-check] failed: branch '$branch' does not contain TASK_ID '$task_id'." >&2
    exit 1
  fi
fi
```

## 验证命令

### 命令 1：正例 - 当前分支包含 TASK_ID

```bash
make workflow-check TASK_ID=phase21-workflow-branch-taskid-gate-v1
```

**预期**：所有门禁通过

### 命令 2：负例 - TASK_ID 不匹配

```bash
# 当前分支不包含 TASK_ID=wrong-task-id-xxx
make workflow-check TASK_ID=wrong-task-id-xxx
```

**预期输出**：
```
[workflow-check] failed: branch 'feat/dev_tools-phase21-workflow-branch-taskid-gate-v1' does not contain TASK_ID 'wrong-task-id-xxx'.
```

## 实际执行摘要（2026-02-17）

- 正例：
  - `make workflow-check TASK_ID=phase21-workflow-branch-taskid-gate-v1`
  - 结果：通过，输出末行为 `[workflow-check] passed.`
- 负例：
  - `make workflow-check TASK_ID=wrong-task-id-xxx`
  - 结果：失败，输出包含 `does not contain TASK_ID 'wrong-task-id-xxx'`

## 风险与回滚

### 风险

- 低风险：仅增加一致性校验
- 无运行时影响：修改的是 CI/提交前检查脚本

### 回滚方案

```bash
git checkout HEAD -- dev/tools/workflow_check.sh
git checkout HEAD -- docs/work_logs/2026-02.md
rm -rf docs/tasks/phase21-workflow-branch-taskid-gate-v1
```

## 建议 Commit Message

```
feat(dev_tools): add branch-TASK_ID consistency gate to workflow-check (phase21)

- Add check to ensure branch name contains the TASK_ID
- Prevents submitting task artifacts to wrong branch
- Skip check for main branch

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
