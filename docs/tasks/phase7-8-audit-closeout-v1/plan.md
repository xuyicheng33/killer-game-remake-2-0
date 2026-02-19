# Task: phase7-8-audit-closeout-v1

- 任务 ID：`phase7-8-audit-closeout-v1`
- 任务级别：`L1`
- 主模块：`process`
- 负责人：`AI`
- 日期：`2026-02-20`

## 目标

对 Phase 7A/7B/7C/8 已完成改动做一次流程收口，补齐 workflow-check 的分支与白名单约束，确保本批次可按门禁验证。

## 范围边界

- 包含：本批次已完成改动的流程闭环验证、任务文档补充、工作日志回填。
- 不包含：新增玩法功能与跨阶段重构。

## 改动白名单文件

- `content/`
- `runtime/`
- `dev/tools/`
- `dev/tests/perf/`
- `docs/tasks/`
- `docs/work_logs/2026-02.md`
- `.gitignore`

## 实施步骤

1. 切换到包含 TASK_ID 的合规分支。
2. 补齐任务计划白名单段，确保 workflow-check 可解析。
3. 运行 `make workflow-check TASK_ID=phase7-8-audit-closeout-v1` 完成门禁验证。

## 验证方案

1. 执行 `HOME=/tmp bash dev/tools/run_gut_tests.sh 180`。
2. 执行 `bash dev/tools/memory_baseline.sh`。
3. 执行 `make workflow-check TASK_ID=phase7-8-audit-closeout-v1`。

## 风险与回滚

- 风险：白名单范围偏大可能降低任务边界精度。
- 回滚方式：回退 `docs/tasks/phase7-8-audit-closeout-v1/` 与本次流程性文档改动。
