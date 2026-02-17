# Plan: phase21-workflow-branch-taskid-gate-v1

## 任务概述

- 任务ID：phase21-workflow-branch-taskid-gate-v1
- 等级：L1
- 主模块：dev_tools
- 目标：为 workflow-check 增加"分支名与 TASK_ID 一致性"门禁，避免在错误分支上提交错误任务产物

## 背景

`workflow_check.sh` 当前分支检查逻辑：
```bash
branch_pattern='^(feat|fix|chore)/[a-z0-9_]+-[a-z0-9._-]+$'
if [[ "$branch" != "main" && ! "$branch" =~ $branch_pattern ]]; then
  echo "[workflow-check] failed: branch '$branch' does not match feat|fix|chore/<module>-<task-id>." >&2
  exit 1
fi
```

问题：只检查分支名格式，未检查分支名是否包含当前 TASK_ID。

这意味着：
- 开发者可能在 `feat/run_flow-phase10-xxx` 分支上运行 `make workflow-check TASK_ID=phase20-yyy`
- 会错误地通过检查并提交

## 设计决策

### 修改方案

在分支格式检查后新增 TASK_ID 一致性检查：
```bash
if [[ "$branch" != "main" ]]; then
  if [[ "$branch" != *"$task_id"* ]]; then
    echo "[workflow-check] failed: branch '$branch' does not contain TASK_ID '$task_id'." >&2
    exit 1
  fi
fi
```

### 特殊处理

- main 分支跳过此检查（允许在 main 上执行 workflow-check）

## 白名单文件

- `dev/tools/workflow_check.sh`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase21-workflow-branch-taskid-gate-v1/`

## 风险评估

- 低风险：仅增加一致性校验，不改其他逻辑
- 回滚：还原 workflow_check.sh 修改即可

## 验收标准

1. workflow-check 正常通过（当前分支包含 TASK_ID）
2. 在不包含 TASK_ID 的分支上 workflow-check 必须失败
3. 任务三件套齐全
