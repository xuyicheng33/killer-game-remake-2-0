# 任务交接

## 基本信息

- 任务 ID：`feat-seed-deterministic-v1`
- 主模块：`save_seed_replay`
- 提交人：Codex
- 日期：2026-02-16

## 当前状态

- 阶段：`C2` 实现完成（待你确认提交）
- 状态：`已实现 + 已记录验证`

## 改动摘要

- 新增统一 RNG 入口：`global/run_rng.gd`
  - 提供 run 级种子初始化、按流派生随机流、统一索引抽样入口。
  - 将“临时 RNG/new + 零散 pick_random/randf”收敛为统一服务。
- 新增最小复现日志：`global/repro_log.gd`
  - 统一输出 `seed/floor/node/enemy` 关键字段，便于定位 run。
- 随机链路接入统一 seed 体系（最小可用）：
  - 地图生成：`modules/map_event/map_generator.gd` 改为通过 `RunRng` 派生流。
  - 事件模板与事件加牌：`modules/map_event/event_service.gd` 接入 `RunRng`。
  - 奖励选牌：`modules/reward_economy/reward_generator.gd` 接入 `RunRng`。
  - 敌方意图加权：`modules/enemy_intent/intent_rules.gd` 接入 `RunRng`。
  - 敌方动作选择日志：`scenes/enemy/enemy_action_picker.gd` 接入 `ReproLog`。
  - run 生命周期：`scenes/app/app.gd` 在新局/读档时初始化 RNG，并记录节点推进日志；支持通过 `STS_RUN_SEED` 指定固定 seed。
- 契约补充：`docs/contracts/run_state.md` 新增 C2 固定种子约束。
- 审核修复（追加）：
  - 修复“读档重置 RNG 流”问题：`RunRng` 增加流状态导出/恢复，`SaveService` 存取 `rng_state`，`App` 读档优先恢复 RNG 流状态。
  - 敌方 stream key 从 `enemy.name + index` 升级为 `map_node_id + enemy_ai_signature + index`，降低命名/层级变更敏感度。
  - 奖励随机去除通用默认 stream，商店改为显式 `shop_offers` stream key，减少隐式耦合。

## 变更文件

- `global/run_rng.gd`
- `global/repro_log.gd`
- `modules/map_event/map_generator.gd`
- `modules/map_event/event_service.gd`
- `modules/reward_economy/reward_generator.gd`
- `modules/reward_economy/shop_offer_generator.gd`
- `modules/enemy_intent/intent_rules.gd`
- `scenes/enemy/enemy_action_picker.gd`
- `scenes/app/app.gd`
- `modules/persistence/save_service.gd`
- `docs/contracts/run_state.md`
- `docs/tasks/feat-seed-deterministic-v1/plan.md`
- `docs/tasks/feat-seed-deterministic-v1/handoff.md`
- `docs/tasks/feat-seed-deterministic-v1/verification.md`

## 验证结果

- [x] `make workflow-check TASK_ID=feat-seed-deterministic-v1`
- [x] `godot4.6 --version`
- [x] `godot4.6 --headless --path /Users/xuyicheng/杀戮游戏复刻2.0 --quit`（已执行；35 秒超时，日志见 verification）
- [ ] 主路径用例 1
- [ ] 主路径用例 2
- [ ] 边界用例 1

说明：功能用例当前为“未运行时实测”，已提供 GUI 可复验步骤（含固定 `STS_RUN_SEED` 方案）。

## 风险与影响范围

- 当前环境 `godot4.6 --headless --quit` 仍挂起，影响自动化运行时验证闭环。
- 随机流已统一到 `RunRng`，但“同 seed 完整战斗回放”仍不在本任务范围内（本任务仅最小可复现目标）。
- 若后续新增随机点未接入 `RunRng`，会引入复现偏差；需作为代码评审检查项。

## 建议提交信息

- `feat(save_seed_replay): add deterministic seed flow v1 (feat-seed-deterministic-v1)`
