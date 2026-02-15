# reward_economy

状态：
- Phase B / B1 `feat-reward-flow-v1`：已接入最小战后奖励（金币 + 三选一卡）。

职责：
- 生成战后奖励内容（金币、卡牌选择等）。
- 应用奖励结果到 `RunState`（写回金币、牌组等）。

当前最小实现：
- `reward_generator.gd`：生成与应用战后奖励（B1 范围：金币 + 三选一卡）。
