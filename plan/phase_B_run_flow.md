# Phase B：一局流程拆分

## 阶段目标

把“单场战斗闭环”扩展为“可连续推进的一局流程”：奖励、路径推进、休息/商店/事件、遗物与药水触发。

## 阶段入口

- Phase A 已完成，核心战斗规则可扩展。
- `RunState` 能稳定承接战后写回。

## 任务拆分

## B1 `feat-reward-flow-v1`

- 级别：`L1`
- 主模块：`reward_economy`
- 依赖：A 阶段完成
- 关键改动路径：
  - `scenes/reward/**`（新建）
  - `modules/reward_economy/**`
  - `scenes/app/**`
  - `modules/run_meta/**`
- 子任务：
  1. 新增战后奖励页（金钱 + 三选一卡）。
  2. 胜利流转从“直接回地图”改为“奖励页 -> 地图”。
  3. 奖励结果写回 `RunState`。
- 验收：赢一场后可选牌并写回牌组。

## B2 `feat-map-graph-progression-v1`

- 级别：`L2`
- 主模块：`map_event`
- 依赖：B1
- 关键改动路径：
  - `modules/map_event/**`
  - `scenes/map/**`
  - `modules/run_meta/**`
  - `docs/contracts/run_state.md`
- 子任务：
  1. 从单层候选改为多层路径图（普通/精英/休息/事件/商店/Boss）。
  2. 节点可达性与已走路径状态管理。
  3. 推进逻辑与楼层/章节信息同步。
- 验收：连续走 5 层，路径状态正确。

## B3 `feat-rest-shop-event-v1`

- 级别：`L2`
- 主模块：`map_event`
- 依赖：B2
- 关键改动路径：
  - `scenes/events/**`（新建）
  - `scenes/shop/**`（新建）
  - `modules/map_event/**`
  - `modules/reward_economy/**`
- 子任务：
  1. 营火：休息/升级二选一。
  2. 商店：买卡/删卡基础流程。
  3. 事件：先落地至少 10 个基础事件模板。
- 验收：对应节点交互后，`RunState` 出现可见变化。

## B4 `feat-relic-potion-core-v1`

- 级别：`L2`
- 主模块：`relic_potion`
- 依赖：A4 + B1
- 关键改动路径：
  - `modules/relic_potion/**`
  - `custom_resources/relics/**`（新建）
  - `custom_resources/potions/**`（新建）
  - `scenes/ui/**`
- 子任务：
  1. 增加遗物栏、药水栏与容量规则。
  2. 接入基础触发链（战斗开始/出牌后/受击后）。
  3. 奖励链路支持掉落遗物/药水。
- 验收：示例遗物/药水触发时有反馈和数值变化。

## 阶段出口

- 从开局到多层推进可持续进行，不再停留于单场战斗 demo。
- `RunState` 具备核心流程字段（楼层、金币、牌组、遗物、药水、事件结果）。
- 地图节点类型在流程中均可触发并回写状态。
