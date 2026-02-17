# 任务交接

## 基本信息

- 任务 ID：`phase4-map-orchestration-decoupling-v1`
- 主模块：`run_flow`
- 提交人：Codex
- 日期：2026-02-17

## 当前状态

- 阶段：`Phase 4（map orchestration decoupling v1）`
- 状态：`已完成`

## 本次迁移了哪些编排

1. 新增 `modules/run_flow/route_dispatcher.gd`：
   - 提供统一路由常量（`battle/reward/rest/shop/event/game_over/map`）。
   - 提供统一命令结果构造（`make_result(next_route, payload)`）。
2. 新增 `modules/run_flow/map_flow_service.gd`：
   - `enter_map_node(run_state, node)`：收口 map node enter 判定与下一路由决策。
   - placeholder/default 节点的 `next_floor` 跳转迁移到该服务。
   - `resolve_non_battle_completion(run_state, node_type)`：收口 rest/shop/event 完成后的 map 路由与 B3 bonus 应用。
3. 更新 `modules/run_flow/run_flow_service.gd`：
   - 聚合注入 `route_dispatcher`、`map_flow_service`。
   - battle flow 与 map flow 共用同一套 route 契约。
4. 更新 `scenes/app/app.gd`：
   - 删除地图节点 `match node.type` 分支编排。
   - 删除 app 层 placeholder `next_floor` 与 B3 bonus 业务写入。
   - 新增 `_dispatch_next_route`，仅负责场景实例化与信号接线。

## 哪些逻辑刻意未动

1. battle/reward/event/shop/rest 规则语义和数值未改。
2. 存档 schema 与 `modules/persistence/save_service.gd` 协议未改。
3. `map_event -> reward_economy` 的历史反向依赖未在本任务处理。
4. `scenes/app/app.gd` 中 checkpoint、repro log、UI 页面实例化职责保留。

## 统一 route 契约

- 统一字典返回：至少包含 `next_route`。
- 常见 payload 字段：
  - `accepted`
  - `node_type`
  - `reward_gold`
  - `bonus_log`
  - `reward_log`
  - `game_over_text`

## 残余风险

1. `app.gd` 仍保留 `pending_node_type` / `pending_reward_gold` 两个流程上下文字段，后续可继续迁移为服务上下文。
2. 当前 route 契约依赖字符串常量，缺少自动化契约测试时容易在后续改动中回归。
3. placeholder 节点当前依赖默认分支语义，新增节点类型时若未在 dispatcher 显式声明，仍会走 map fallback。

## Phase 5 建议

1. 在 `run_flow` 引入轻量 `flow_context`（承接 `pending_*`），进一步缩减 `app.gd` 状态字段。
2. 为 `map_flow_service` / `battle_flow_service` 添加最小契约测试，覆盖 `next_route` 和关键 payload。
3. 将 `app.gd` 的 checkpoint/repro 触发点封装成 `run_flow` 钩子，继续收口应用编排。

## 变更文件

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
- `docs/tasks/phase4-map-orchestration-decoupling-v1/plan.md`
- `docs/tasks/phase4-map-orchestration-decoupling-v1/handoff.md`
- `docs/tasks/phase4-map-orchestration-decoupling-v1/verification.md`
