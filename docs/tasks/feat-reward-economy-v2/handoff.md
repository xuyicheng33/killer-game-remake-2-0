# 交接文档：feat-reward-economy-v2

**任务ID**: `feat-reward-economy-v2`
**完成日期**: 2026-02-18
**执行人**: 程序员

---

## 改动文件

| 文件 | 改动类型 | 说明 |
|---|---|---|
| `runtime/modules/reward_economy/shop_offer_generator.gd` | 修改 | 遗物/药水报价 + 购买逻辑 |
| `runtime/modules/run_meta/run_state.gd` | 修改 | 新增 `card_removal_count` 字段 |

---

## 关键改动

### 商店完整报价

```gdscript
static func generate_full_offers(run_state: RunState) -> Dictionary:
    return {
        "cards": [...],
        "relics": [...],
        "potions": [...],
        "remove_price": ...,
    }
```

### 购买逻辑

- `buy_card(run_state, card, price) -> bool`
- `buy_relic(run_state, relic, price) -> bool`
- `buy_potion(run_state, potion, price) -> bool`
- `remove_card(run_state, card) -> bool`

### 价格设置

- 卡牌：55 金币
- 药水：50 金币
- 遗物：150-300 金币（按稀有度）
- 删卡：75 + 25 * 次数

---

## 已知问题

无

---

## 建议 commit message

```
feat(reward_economy): add relic/potion shop support (feat-reward-economy-v2)

- Add generate_full_offers()
- Implement buy_card/relic/potion/remove_card
- Add card_removal_count to RunState
```
