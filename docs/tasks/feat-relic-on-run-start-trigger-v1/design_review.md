# 设计复核

## 任务 ID
`feat-relic-on-run-start-trigger-v1`

## 当前实现位置（文件 + 关键点）

- `runtime/modules/relic_potion/relic_potion_system.gd`
  - `TriggerType` 已包含 `ON_RUN_START`
  - `bind_run_state()` 中会触发 `_fire_trigger(ON_RUN_START, {})`
  - `_process_relic_trigger()` 没有 `ON_RUN_START` 分支
- `content/custom_resources/relics/relic_data.gd`
  - 无 `on_run_start_*` 相关导出字段
- `runtime/modules/persistence/save_service.gd`
  - 遗物扩展字段可序列化，但没有“开局一次性触发已消费”状态

## 当前数据结构与限制

- 触发器存在，但没有数据字段与执行逻辑可承接 `ON_RUN_START`
- 当前仅能用 `on_battle_start_heal` 近似表达，无法满足主计划“开局永久增益”语义

## 可复用点

- `RelicPotionSystem._dispatch_effect()` 可复用执行通道
- `RunState` 已可持有遗物列表并支持存档恢复

## 风险点

- 读档后重复触发风险（需一次性触发幂等保障）
- 新字段加入 `RelicData` 后需同步存档兼容
- “永久增益”需定义精确作用域（整局/战斗内/回合内）
