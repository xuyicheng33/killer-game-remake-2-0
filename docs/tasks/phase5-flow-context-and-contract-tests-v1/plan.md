# 任务计划

## 基本信息

- 任务 ID：`phase5-flow-context-and-contract-tests-v1`
- 任务级别：`L2`
- 主模块：`run_flow`
- 负责人：Codex
- 日期：2026-02-17

## 目标

将 `app.gd` 残留流程上下文（`pending_node_type` / `pending_reward_gold`）收口到 `run_flow`，并补齐最小可脚本化契约测试，防止路由与 payload 回归。

## 范围边界

- 包含：
  - 在 `modules/run_flow` 引入轻量 `flow_context` 并迁移 `pending_*`。
  - `app.gd` 继续瘦身，只保留事件接线、场景实例化、路由执行入口。
  - 消除 `battle_flow_service` 的重复路由常量定义，统一复用 `route_dispatcher` 常量。
  - 新增最小契约测试脚本，覆盖 map_flow/battle_flow/non-battle completion 关键契约。
  - 同步更新模块与架构文档、任务三件套。
- 不包含：
  - 玩法规则语义变更（数值、触发时机）。
  - 存档 schema 与 persistence 协议变更。
  - 新增 domain -> scenes 反向依赖。
  - 跨模块大规模重构。

## 改动白名单文件

- `modules/run_flow/flow_context.gd`
- `modules/run_flow/run_flow_service.gd`
- `modules/run_flow/battle_flow_service.gd`
- `modules/run_flow/README.md`
- `scenes/app/app.gd`
- `tools/run_flow_contract_check.sh`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase5-flow-context-and-contract-tests-v1/**`

## 实施步骤

1. 新增 `flow_context.gd`，将 `pending_node_type` / `pending_reward_gold` 从 app 状态迁移到 run_flow 服务上下文。
2. 更新 `run_flow_service.gd` 对外暴露上下文读写接口；`app.gd` 改为通过服务读写上下文。
3. 更新 `battle_flow_service.gd`，删除重复路由常量并复用 `RunRouteDispatcher` 常量。
4. 新增 `tools/run_flow_contract_check.sh`，覆盖：
   - map node type -> next_route 映射
   - battle win/lose 路由与关键 payload
   - non-battle completion 的 `bonus_log` 契约字段
5. 更新 `run_flow` README 与架构文档、任务三件套。

## 验证方案

1. `rg -n "pending_node_type|pending_reward_gold" scenes/app/app.gd modules/run_flow`
2. `rg -n "ROUTE_(MAP|BATTLE|REWARD|REST|SHOP|EVENT|GAME_OVER)" modules/run_flow`
3. `bash tools/run_flow_contract_check.sh`
4. `make workflow-check TASK_ID=phase5-flow-context-and-contract-tests-v1`

## 风险与回滚

- 风险：上下文迁移后若漏掉默认值回填，可能导致 battle/reward 路由参数丢失。
- 风险：契约测试仅覆盖关键键位，无法替代完整运行时回归。
- 回滚方式：回滚 `run_flow` + `app.gd` + 契约脚本改动即可恢复 Phase 4 路径。
