# reward_economy

状态：
- Phase B / B3 `feat-rest-shop-event-v1`：已补充商店供货生成（买卡/删卡的最小支持）。

职责：
- 生成战后奖励内容（金币、卡牌选择等）。
- 应用奖励结果到 `RunState`（写回金币、牌组等）。
- 提供商店可购买卡供货（最小规则）。

当前最小实现：
- `reward_generator.gd`：生成与应用战后奖励（B1 范围：金币 + 三选一卡）。
- `shop_offer_generator.gd`：生成商店售卖卡项与基础定价。
