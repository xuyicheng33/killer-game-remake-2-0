# 任务交接

## 基本信息

- 任务 ID：`phase12-run-flow-lifecycle-contract-gate-v1`
- 主模块：`run_flow`
- 提交人：AI 程序员
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 12`
- 状态：`已完成（待用户验证）`

## 改动摘要

1. 新增 `dev/tools/run_lifecycle_contract_check.sh`：
   - 禁止 `app.gd` 直接 preload/use `persistence/save_service.gd`、`run_rng.gd`、`repro_log.gd`。
   - 强制 `app.gd` 通过 `run_flow_service.lifecycle_service` 调用 `start_new_run/try_load_saved_run/save_checkpoint`。
   - 目的：防止后续回归把生命周期逻辑再次耦合到入口场景。
2. 更新 `dev/tools/workflow_check.sh`，串行纳入 `run_lifecycle_contract_check.sh`。
3. 同步更新 `modules/run_flow/README.md` 与架构文档（`module_boundaries_v1` / `module_architecture` / `work_logs`）。

## 变更文件

| 文件 | 变更类型 |
|---|---|
| `dev/tools/run_lifecycle_contract_check.sh` | 新增 |
| `dev/tools/workflow_check.sh` | 修改 |
| `runtime/modules/run_flow/README.md` | 修改 |
| `docs/contracts/module_boundaries_v1.md` | 修改 |
| `docs/module_architecture.md` | 修改 |
| `docs/work_logs/2026-02.md` | 修改 |

## 验证结果

- [x] 代码改动完成
- [x] `bash dev/tools/run_lifecycle_contract_check.sh`（已通过）
- [x] `make workflow-check TASK_ID=phase12-run-flow-lifecycle-contract-gate-v1`（已通过）

## 风险与影响范围

- **风险**：无（本任务只新增门禁脚本，不修改业务代码）。
- **影响范围**：仅影响工作流检查脚本，不影响游戏运行时逻辑。
- **回滚方案**：回滚本任务所有白名单文件。

## 建议提交信息

- `feat(run_flow): add lifecycle contract gate to prevent app.gd regression（phase12-run-flow-lifecycle-contract-gate-v1）`
