# 任务交接

## 基本信息

- 任务 ID：`phase3-battle-flow-decoupling-v1`
- 主模块：`run_flow`
- 提交人：Codex
- 日期：2026-02-16

## 当前状态

- 阶段：`Phase 3（battle flow decoupling 第一批）`
- 状态：`已完成`

## 本次迁移了哪些逻辑

1. 新增 `modules/run_flow/battle_flow_service.gd`：
   - `resolve_battle_completion(run_state, is_win, reward_gold)`
   - `apply_battle_reward(run_state, bundle, chosen_card)`
2. 在 `modules/run_flow/run_flow_service.gd` 注入 `battle_flow_service` 子服务。
3. `scenes/app/app.gd` 中以下编排迁移到服务层：
   - battle 胜负后路由判定（reward/game_over/map）
   - 失败分支存档清理与 game over 文案生成
   - 奖励应用（`apply_post_battle_reward`）
4. app 层保留：
   - battle 结束事件监听与 UI 页面切换
   - `relic_potion_system` 的开始/结束战斗接线
   - 地图节点选择与其他非本批流程

## 哪些逻辑刻意未动

1. `battle` 规则链路（状态机、出牌/敌方行为）未改。
2. `reward_economy` 的奖励数值与规则未改。
3. 存档 schema 与读写协议未改。
4. `scenes/app/app.gd` 中地图推进主流程（如 `enter_map_node`、占位 `next_floor`）未纳入本批迁移。

## 命令返回契约

- `BattleFlowService` 统一返回 `Dictionary`，至少包含：
  - `next_route`: `reward | game_over | map`
- 可选字段：
  - `reward_gold`
  - `game_over_text`
  - `reward_log`

## 剩余风险与下一步建议

1. 风险：`app.gd` 仍是流程中枢，后续迁移需避免一次性重写。
2. 风险：`map_event -> reward_economy` 反向依赖仍在。
3. 建议下一步：
   - 将 `app.gd` 的地图节点进入与分支路由继续迁至 `run_flow`。
   - 抽离统一路由器（route dispatcher），减少 app match 分支。
   - 为 `run_flow` 命令结果补最小单元测试/契约测试。

## 变更文件

- `modules/run_flow/battle_flow_service.gd`
- `modules/run_flow/run_flow_service.gd`
- `modules/run_flow/README.md`
- `scenes/app/app.gd`
- `docs/contracts/module_boundaries_v1.md`
- `docs/module_architecture.md`
- `docs/repo_structure.md`
- `docs/tasks/phase3-battle-flow-decoupling-v1/plan.md`
- `docs/tasks/phase3-battle-flow-decoupling-v1/handoff.md`
- `docs/tasks/phase3-battle-flow-decoupling-v1/verification.md`
- `docs/work_logs/2026-02.md`
