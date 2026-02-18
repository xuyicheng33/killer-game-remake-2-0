# 设计提案：feat-reward-economy-v2

**任务ID**: `feat-reward-economy-v2`
**提案日期**: 2026-02-18

---

## 目标效果

扩展商店系统支持遗物和药水购买：
1. 商店生成遗物报价（1-2个，价格100-300金币）
2. 商店生成药水报价（1-2个，价格50金币）
3. 购买逻辑：扣金币、加入 RunState
4. 商店库存规格：3张卡 + 1个遗物 + 1个药水

---

## 非目标（不做什么）

- 不修改商店 UI 布局
- 不修改金币获取逻辑
- 不引入新的货币类型
- 不修改删卡的基础逻辑（仅调整价格递增）

---

## 方案 A（推荐）

### 扩展 ShopOfferGenerator

```gdscript
static func generate_full_offers(run_state: RunState) -> Dictionary:
    var cards := _generate_card_offers(run_state)
    var relics := _generate_relic_offers(run_state)
    var potions := _generate_potion_offers(run_state)
    
    return {
        "cards": cards,
        "relics": relics,
        "potions": potions,
        "remove_price": _calculate_remove_price(run_state),
    }

static func _generate_relic_offers(run_state: RunState) -> Array[Dictionary]:
    var offers: Array[Dictionary] = []
    var relic := RelicCatalog.pick_random(_shop_stream_key(run_state) + ":relic")
    if relic != null:
        offers.append({
            "relic": relic,
            "price": _relic_price(relic),
        })
    return offers

static func _generate_potion_offers(run_state: RunState) -> Array[Dictionary]:
    var offers: Array[Dictionary] = []
    var potion := PotionCatalog.pick_random(_shop_stream_key(run_state) + ":potion")
    if potion != null:
        offers.append({
            "potion": potion,
            "price": 50,
        })
    return offers
```

### 购买逻辑

```gdscript
func buy_relic(run_state: RunState, relic: RelicData, price: int) -> bool:
    if run_state.gold < price:
        return false
    run_state.add_gold(-price)
    run_state.relics.append(relic)
    return true

func buy_potion(run_state: RunState, potion: PotionData, price: int) -> bool:
    if run_state.gold < price:
        return false
    if run_state.potions.size() >= 3:
        return false
    run_state.add_gold(-price)
    run_state.potions.append(potion)
    return true
```

---

## 方案 B（备选）

购买逻辑放在 ShopFlowService 而非 ShopOfferGenerator。

**权衡**:
- 方案 A 优点：报价生成与购买逻辑集中
- 方案 B 优点：符合现有分层结构

**选择方案 A 原因**: 当前 ShopOfferGenerator 已包含价格计算，保持一致性。

---

## 对现有逻辑的影响

| 影响项 | 说明 |
|---|---|
| ShopOfferGenerator | 新增遗物/药水报价生成 |
| ShopFlowService | 需要处理新的购买类型 |
| RunState | 无影响（已有 relics/potions 字段） |

---

## 对存档的影响

无影响。遗物和药水已在 RunState 中正确序列化。

---

## 对种子一致性的影响

低影响。商店报价使用 RunRng.pick_index()，相同种子产生相同报价。

---

## 测试计划

| 测试用例 | 验证内容 |
|---|---|
| `test_shop_purchase_relic_deducts_gold()` | 购买遗物扣金币 |
| `test_shop_purchase_potion_respects_inventory_limit()` | 药水槽上限 |
| `test_card_removal_cost_increases_after_first_use()` | 删卡价格递增 |
| `test_shop_offers_same_seed_same_offers()` | 相同种子相同报价 |

---

## 请求批准

请确认是否批准此设计方案，以便进入编码阶段。
