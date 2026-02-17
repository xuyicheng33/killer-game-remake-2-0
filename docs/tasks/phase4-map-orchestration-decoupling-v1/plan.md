# 任务计划

## 基本信息

- 任务 ID：`phase4-map-orchestration-decoupling-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：Codex
- 日期：2026-02-17

## 目标

继续推进 `run_flow` 应用层收口：将地图节点进入判定、分支路由与页面切换决策从 `scenes/app/app.gd` 迁移到 `modules/run_flow`，统一命令返回契约为 `next_route + payload`，并保持行为等价。

## 范围边界

- 包含：
  - 在 `modules/run_flow` 新增 `map_flow_service` 与 `route_dispatcher`。
  - 迁移 `app.gd` 中地图节点进入 + placeholder `next_floor` + open_* 分支决策到 `run_flow` 命令。
  - 统一路线契约字段（至少 `next_route`，并补充 `node_type` / `reward_gold` / `bonus_log` 等 payload）。
  - 同步更新模块与架构文档。
- 不包含：
  - battle/reward/event/shop/rest 的数值与规则语义变更。
  - 存档 schema 与 persistence 协议变更。
  - 新增 domain -> scenes 反向依赖。
  - 跨模块重写或大规模目录搬迁。

## 改动白名单文件

- `modules/run_flow/route_dispatcher.gd`
- `modules/run_flow/map_flow_service.gd`
- `modules/run_flow/run_flow_service.gd`
- `modules/run_flow/battle_flow_service.gd`
- `modules/run_flow/README.md`
- `scenes/app/app.gd`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase4-map-orchestration-decoupling-v1/**`

## 实施步骤

1. 新增 `RunRouteDispatcher`，统一路由常量与结果构造函数。
2. 新增 `MapFlowService`，承接 map node enter 判定、placeholder 跳层、非战斗节点完成后路由决策。
3. 更新 `RunFlowService` 聚合注入新服务；`BattleFlowService` 对齐统一结果构造。
4. 改造 `scenes/app/app.gd`：移除 node type `match` 与直接流程写入，改为 `_dispatch_next_route` 路由执行。
5. 更新 `run_flow/README` 与架构文档。
6. 补齐 phase4 三件套并执行验证命令与 workflow-check。

## 验证方案

1. `rg -n "run_state\\.(enter_map_node|next_floor|set_|add_|remove_|clear_|advance_|mark_|apply_)" scenes/app/app.gd`
2. `rg -n "next_route" modules/run_flow scenes/app/app.gd`
3. `make workflow-check TASK_ID=phase4-map-orchestration-decoupling-v1`

## 风险与回滚

- 风险：路由常量或 payload 字段拼写不一致会导致页面分支错误。
- 风险：地图节点进入成功与否的判定若回传不完整，可能造成 UI 无响应。
- 回滚：回滚 `run_flow` 新服务与 `app.gd` 接线改动即可恢复 Phase 3 路径。
