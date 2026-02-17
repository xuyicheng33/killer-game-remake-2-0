# 任务交接

## 基本信息

- 任务 ID：`phase5-flow-context-and-contract-tests-v1`
- 主模块：`run_flow`
- 提交人：Codex
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 5（flow context and contract tests v1）`
- 状态：`已完成`

## 改动摘要

1. 新增 `modules/run_flow/flow_context.gd`：
   - 统一承接跨页面流程上下文 `pending_node_type` / `pending_reward_gold`。
   - 提供 `reset/apply_map_node_result/apply_route_result/reward_gold_for` 轻量接口。
2. 更新 `modules/run_flow/run_flow_service.gd`：
   - 聚合 `flow_context` 并提供上下文接线函数（`reset_flow_context`、`apply_map_node_context`、`apply_route_context` 等）。
3. 更新 `scenes/app/app.gd`：
   - 删除 app 层 `pending_*` 字段。
   - battle/reward/non-battle 流程均改为通过 `run_flow_service` 读取上下文。
   - app 保留“事件接线 + 场景实例化 + 路由执行入口”职责。
4. 更新 `modules/run_flow/battle_flow_service.gd`：
   - 删除本地重复路由常量（`reward/game_over/map`）。
   - 统一复用 `RunRouteDispatcher` 常量单点定义。
5. 新增 `dev/tools/run_flow_contract_check.sh` 最小契约测试：
   - 校验 map node type -> next_route 映射（`route_dispatcher`）。
   - 校验 battle win/lose 路由与关键 payload（`reward_gold` / `game_over_text`）。
   - 校验 non-battle completion 的 `bonus_log` payload 键。

## 哪些逻辑刻意未动

1. 玩法规则语义（数值、触发时机）未改。
2. 存档 schema 与 persistence 协议未改。
3. 未新增 domain -> scenes 反向依赖。
4. app 层 checkpoint/repro log 触发点维持现状。

## 变更文件

- `modules/run_flow/flow_context.gd`
- `modules/run_flow/run_flow_service.gd`
- `modules/run_flow/battle_flow_service.gd`
- `modules/run_flow/README.md`
- `scenes/app/app.gd`
- `dev/tools/run_flow_contract_check.sh`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/work_logs/2026-02.md`
- `docs/tasks/phase5-flow-context-and-contract-tests-v1/plan.md`
- `docs/tasks/phase5-flow-context-and-contract-tests-v1/handoff.md`
- `docs/tasks/phase5-flow-context-and-contract-tests-v1/verification.md`

## 风险与影响范围

1. 当前契约测试为最小集合，主要防止路由键与关键 payload 回归，不覆盖完整运行时行为。
2. `flow_context` 仍是应用层状态对象；若后续继续收口 app 编排，需要同步补充对应契约测试。

## 建议提交信息

- `feat(run_flow): 收口 flow_context 并新增路由契约测试（phase5-flow-context-and-contract-tests-v1）`
