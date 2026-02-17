# 任务计划

## 基本信息

- 任务 ID：`phase12-run-flow-lifecycle-contract-gate-v1`
- 任务级别：`L1`
- 主模块：`run_flow`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

为 phase11 的生命周期解耦增加"可执行门禁"，防止后续回归把 app.gd 再次耦合到 persistence/run_rng/repro_log。本任务只做契约门禁与文档回填，不做玩法改动。

## 范围边界

- 包含：
  - 新增脚本：`dev/tools/run_lifecycle_contract_check.sh`
  - 接入总门禁：修改 `dev/tools/workflow_check.sh`
  - 文档同步：`run_flow/README.md`、`module_boundaries_v1.md`、`module_architecture.md`、`docs/work_logs/2026-02.md`
- 不包含：
  - 玩法改动
  - 业务代码修改
  - 新存档格式设计

## 改动白名单文件

- `dev/tools/run_lifecycle_contract_check.sh`（新建）
- `dev/tools/workflow_check.sh`
- `runtime/modules/run_flow/README.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase12-run-flow-lifecycle-contract-gate-v1/plan.md`
- `docs/tasks/phase12-run-flow-lifecycle-contract-gate-v1/handoff.md`
- `docs/tasks/phase12-run-flow-lifecycle-contract-gate-v1/verification.md`

## 实施步骤

1. 新增 `run_lifecycle_contract_check.sh`：
   - 检查 `app.gd` 不得直接 preload/use `persistence/save_service.gd`、`run_rng.gd`、`repro_log.gd`。
   - 检查 `app.gd` 必须通过 `run_flow_service.lifecycle_service` 调用生命周期方法。
2. 修改 `workflow_check.sh`，串行纳入新门禁。
3. 更新相关文档回填门禁说明。

## 验证方案

1. `bash dev/tools/run_lifecycle_contract_check.sh`
2. `make workflow-check TASK_ID=phase12-run-flow-lifecycle-contract-gate-v1`

## 风险与回滚

- 风险：无（本任务只新增门禁脚本，不修改业务代码）。
- 回滚方式：回滚本任务白名单文件。
