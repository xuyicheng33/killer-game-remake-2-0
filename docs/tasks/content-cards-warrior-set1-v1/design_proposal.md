# 设计提案（内容填充简化）

## 任务 ID
`content-cards-warrior-set1-v1`

## 目标效果
- 新增 4 张战士卡，覆盖：格挡技能、能力、消耗、X 费。
- 保持卡牌定义继续由 `warrior_cards.json` 驱动，并通过既有导入器生成资源。

## 非目标
- 不新增 effect op（如抽牌、回能等）。
- 不改动 `RewardGenerator`、`ShopOfferGenerator` 等运行时抽取逻辑。

## 方案
- 方案 A（采用）：直接扩展 `warrior_cards.json`，沿用 `content_import_cards.py` 输出流程。
- 方案 B（不采用）：手写 `.gd/.tres` 卡资源；该方案会绕开数据源，不符合“数据驱动”要求。

## 兼容性影响
- 存档：无结构变化。
- 种子一致性：本任务不改 RNG 算法；仅扩展卡内容集合。
