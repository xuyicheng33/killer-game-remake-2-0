# 设计提案（内容填充简化）

## 任务 ID
`content-relics-set2-v1`

## 目标效果
- 遗物数量达到 8。
- 覆盖 `ON_SHOP_ENTER` 内容语义。

## 非目标
- 不在本任务内独立设计新机制（由 `feat-relic-on-run-start-trigger-v1` 承接）。

## 方案
- 方案 A（采用）：新增资源文件，并联动 `feat-relic-on-run-start-trigger-v1` 落地 `on_run_start_*` 字段与触发链。
- 方案 B（不采用）：仅保留近似语义；无法通过 `ON_RUN_START` 验收。

## 兼容性影响
- 存档：无结构变化。
- 种子一致性：不改 RNG 算法。
