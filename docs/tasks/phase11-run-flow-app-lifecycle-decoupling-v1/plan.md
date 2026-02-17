# 任务计划

## 基本信息

- 任务 ID：`phase11-run-flow-app-lifecycle-decoupling-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：AI 程序员
- 日期：2026-02-17

## 目标

继续瘦身 `runtime/scenes/app/app.gd`，把新局初始化、读档恢复、checkpoint 存档与复盘日志接线收口到 `run_flow` 生命周期服务，降低入口场景复杂度。

## 范围边界

- 包含：
  - 在 `run_flow` 内新增生命周期服务（可命名 `run_lifecycle_service.gd`）。
  - `app.gd` 改为“接收命令结果 + 场景切换”，不直接承载生命周期细节。
  - 关键返回契约补充到 `run_flow_contract_check`（如必要）。
- 不包含：
  - 路由规则语义调整（map/battle/reward 分支不改）。
  - 新存档格式设计（沿用 `persistence` 现有接口）。
  - UI 视觉改造。

## 改动白名单文件

- `runtime/modules/run_flow/run_flow_service.gd`
- `runtime/modules/run_flow/run_lifecycle_service.gd`
- `runtime/scenes/app/app.gd`
- `runtime/modules/run_flow/README.md`
- `dev/tools/run_flow_contract_check.sh`
- `docs/module_architecture.md`
- `docs/contracts/module_boundaries_v1.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase11-run-flow-app-lifecycle-decoupling-v1/plan.md`
- `docs/tasks/phase11-run-flow-app-lifecycle-decoupling-v1/handoff.md`
- `docs/tasks/phase11-run-flow-app-lifecycle-decoupling-v1/verification.md`

## 实施步骤

1. 提取 `app.gd` 中生命周期相关逻辑到 `run_lifecycle_service.gd`。
2. 在 `run_flow_service` 聚合注入生命周期服务。
3. 改造 `app.gd` 调用链，保持对外行为等价。
4. 如新增关键契约字段，更新 `run_flow_contract_check.sh` 与文档。

## 验证方案

1. 新开一局 -> 地图 -> 战斗 -> 奖励 -> 返回地图。
2. 存档退出 -> 继续游戏 -> 地图恢复成功。
3. 战斗失败 -> Game Over 页面行为保持一致。
4. `make workflow-check TASK_ID=phase11-run-flow-app-lifecycle-decoupling-v1`

## 风险与回滚

- 风险：生命周期时序改动可能造成读档后状态未绑定或 checkpoint 丢失。
- 风险：`app.gd` 与 `run_flow` 双方职责边界不清导致重复调用。
- 回滚方式：回滚本任务白名单文件，恢复 `app.gd` 原生命周期实现。
