# 设计提案

## 任务 ID
`feat-relic-on-run-start-trigger-v1`

## 目标

- 为遗物提供真实 `ON_RUN_START` 可执行机制
- 满足 Phase 3b 对 `ON_RUN_START + ON_SHOP_ENTER` 的触发要求

## 非目标

- 不改商店折扣机制（`ON_SHOP_ENTER` 已有）
- 不重构整套遗物系统

## 方案 A（推荐）

1. 扩展 `RelicData` 字段（最小集）：
   - `on_run_start_gold: int = 0`
   - `on_run_start_max_health: int = 0`
2. 在 `RelicPotionSystem._process_relic_trigger()` 增加 `ON_RUN_START` 分支。
3. 在 `RunState` 增加一次性触发标记（`run_start_relics_applied: bool`），防止读档重复触发。
4. 存档层补序列化/反序列化字段，保证兼容。

优点：
- 语义清晰，数据驱动
- 幂等可控，避免重复触发

缺点：
- 涉及 `RunState` 与存档字段变更

## 方案 B

- 复用 `on_battle_start_heal` 近似替代

缺点：
- 不满足需求定义，审核已明确驳回

## 对存档与种子影响

- 存档：新增“run_start 已触发记录”字段，需默认值兼容旧档
- 种子一致性：不新增随机行为

## 验收建议

- 新增遗物 `ON_RUN_START` 触发可在新局立即生效
- 读档后不重复触发
- 相关测试通过（触发一次性 + 存档往返）
