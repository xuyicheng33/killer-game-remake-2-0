# Plan: phase22-workflow-branch-gate-selfcheck-v1

## 任务概述

- 任务ID：phase22-workflow-branch-gate-selfcheck-v1
- 等级：L1
- 主模块：dev_tools
- 目标：补一份 workflow-check 分支门禁的自检脚本，自动覆盖 3 个场景

## 背景

Phase 21 新增了分支名与 TASK_ID 一致性门禁。为确保该门禁逻辑正确，需要补一份自检脚本，自动测试以下场景：

1. 分支名格式非法 -> 失败
2. 分支名合法但不含 TASK_ID -> 失败
3. 分支名合法且包含 TASK_ID -> 通过

## 设计决策

### 自检脚本设计

`workflow_branch_gate_selfcheck.sh` 包含：

1. **场景 1 测试**：非法分支名格式
   - `invalid-branch`
   - `feature/wrong-format`
   - `feat/WRONG-CASE`
   - `fix/no-dash-separator`

2. **场景 2 测试**：合法分支名不含 TASK_ID
   - 使用不存在的 TASK_ID 验证

3. **场景 3 测试**：合法分支名包含 TASK_ID
   - 使用当前分支或模拟分支验证

### 输出格式

- 统一 `[PASS]/[FAIL]` 格式
- 失败时打印上下文

## 白名单文件

- `dev/tools/workflow_branch_gate_selfcheck.sh`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase22-workflow-branch-gate-selfcheck-v1/`

## 风险评估

- 低风险：仅新增自检脚本，不修改现有逻辑
- 回滚：删除新增文件即可

## 验收标准

1. 自检脚本执行成功，输出 `[branch_gate_selfcheck] all checks passed.`
2. 3 个场景测试全部通过
3. 任务三件套齐全
