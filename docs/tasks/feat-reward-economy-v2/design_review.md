# 设计复核：feat-reward-economy-v2

**任务ID**: `feat-reward-economy-v2`
**复核日期**: 2026-02-18

---

## 当前实现位置

**文件**: `runtime/modules/reward_economy/shop_offer_generator.gd`

**关键函数**:
- `generate_offers(run_state)` → 生成卡牌报价
- `_shop_stream_key(run_state)` → 生成随机流键

**常量**:
- `BUY_PRICE := 55`
- `REMOVE_PRICE := 75`
- `SHOP_OFFER_COUNT := 3`

---

## 当前数据结构

返回的报价结构：
```gdscript
[
    {"card": Card, "price": 55},
    {"card": Card, "price": 55},
    {"card": Card, "price": 55},
]
```

---

## 当前限制

1. **仅支持卡牌**: 无法生成遗物/药水报价
2. **无购买逻辑**: 仅生成报价，不处理购买
3. **无价格差异化**: 所有卡牌价格相同

---

## 复用点

1. `RelicCatalog.pick_random()` 可复用
2. `PotionCatalog.pick_random()` 可复用
3. `RunState.add_gold()` / `RunState.relics` / `RunState.potions` 可复用
4. `_shop_stream_key()` 的随机流键生成逻辑可复用

---

## 风险点

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 遗物价格需要按稀有度区分 | 低 | 添加 _relic_price() 辅助函数 |
| 药水槽上限检查遗漏 | 中 | 在购买逻辑中检查 potions.size() < 3 |
| 种子一致性 | 低 | 使用 RunRng 而非全局随机 |

---

## 结论

ShopOfferGenerator 结构简单，需要：
1. 扩展返回结构
2. 新增遗物/药水报价生成
3. 集成购买流程
