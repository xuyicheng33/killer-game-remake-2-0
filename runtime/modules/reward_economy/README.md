# reward_economy

状态：
- Phase B / B4 `feat-relic-potion-core-v1`：已接入遗物/药水奖励发放。

职责：
- 生成战后奖励内容（金币、卡牌选择等）。
- 应用奖励结果到 `RunState`（写回金币、牌组等）。
- 提供商店可购买卡供货（最小规则）。
- 提供 B3 节点额外发放（遗物/药水）最小规则。

当前最小实现：
- `reward_generator.gd`：生成与应用战后奖励（B1 范围：金币 + 三选一卡）。
- `shop_offer_generator.gd`：生成商店售卖卡项与基础定价。
- `reward_generator.gd`（B4 增量）：支持遗物/药水奖励与 B3 节点奖励落袋逻辑。
