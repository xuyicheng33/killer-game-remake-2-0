# 设计复核：feat-relic-potion-v2

**任务ID**: `feat-relic-potion-v2`
**复核日期**: 2026-02-18

---

## 当前实现位置

**文件**: `runtime/modules/relic_potion/relic_potion_system.gd`

**关键函数**:
- `start_battle()` → 触发 ON_BATTLE_START
- `_on_card_played()` → 触发 ON_CARD_PLAYED
- `_on_player_hit()` → 触发 ON_DAMAGE_TAKEN

---

## 当前数据结构

遗物数据存储在 `RelicData`（Resource）中，字段包括：
- `on_battle_start_heal: int`
- `on_card_played_gold: int`
- `card_play_interval: int`
- `on_player_hit_block: int`

药水数据存储在 `PotionData`（Resource）中。

---

## 当前限制

1. **触发时机硬编码**: 每种触发时机单独处理，无法统一扩展
2. **无统一接口**: 遗物效果分散在各处
3. **直接修改状态**: 效果直接操作 RunState，不经过 EffectStack

---

## 复用点

1. `RelicCatalog` 和 `PotionCatalog` 的随机选取逻辑可复用
2. `RelicPotionSystem` 的信号连接模式可复用
3. 现有遗物数据字段可保留，作为简化配置

---

## 风险点

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 现有遗物数据需要适配 | 中 | 保留旧字段，RelicBase 作为扩展层 |
| 触发枚举遗漏 | 低 | 按实际需求逐步补充 |
| 效果派发时序 | 中 | 明确触发顺序，单元测试覆盖 |

---

## 结论

RelicPotionSystem 已有基础框架，需要：
1. 抽象触发时机枚举
2. 标准化遗物效果接口
3. 集成 EffectStack
