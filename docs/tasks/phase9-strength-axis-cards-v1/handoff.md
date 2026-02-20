# Handoff: phase9-strength-axis-cards-v1

## 交付摘要

Phase 9 完成，实现了力量爆发轴卡牌扩展和配套系统：

1. **9-0 遗物 Tooltip 修复**：移除固定高度限制，支持完整描述显示
2. **9-1 卡牌 UI 改造**：图标改为名称+效果描述文本
3. **9-2 新增 10 张卡牌**：力量轴核心卡（30 张总卡池）
4. **9-3 新增 2 个遗物**：战怒之戒、淬炼石

## 改动文件

### UI 系统
- `runtime/scenes/ui/tooltip.tscn` - 移除固定高度
- `runtime/scenes/ui/tooltip.gd` - 添加 reset_size()
- `runtime/scenes/app/app.tscn` - 移除 Tooltip 固定高度
- `runtime/scenes/card_ui/card_ui.tscn` - Icon → VBoxContainer
- `runtime/scenes/card_ui/card_ui.gd` - 绑定名称和描述

### 卡牌系统
- `runtime/modules/content_pipeline/sources/cards/warrior_cards.json` - 30 张卡
- `content/characters/warrior/cards/generated/*.gd` - 自动生成
- `content/characters/warrior/cards/generated/*.tres` - 自动生成
- `content/effects/lose_hp_effect.gd` - 失去HP效果（绕过格挡）
- `content/effects/conditional_damage_effect.gd` - 条件伤害
- `content/effects/strength_multiplier_damage_effect.gd` - 力量倍率伤害
- `content/effects/missing_hp_block_effect.gd` - 缺失HP格挡

### 遗物系统
- `content/custom_resources/relics/relic_data.gd` - 3 个新字段
- `runtime/modules/relic_potion/data_driven_relic.gd` - 新触发逻辑
- `runtime/modules/relic_potion/relic_potion_system.gd` - 触发计数器
- `runtime/modules/relic_potion/relic_catalog.gd` - 字段解析
- `runtime/modules/persistence/save_service.gd` - 字段持久化
- `content/custom_resources/relics/rage_ring.tres` - 战怒之戒
- `content/custom_resources/relics/tempering_stone.tres` - 淬炼石
- `runtime/modules/content_pipeline/sources/relics/examples/common_relics.json` - 18 个遗物

### Buff 系统
- `runtime/modules/buff_system/buff_system.gd` - 伤害倍率 API

### 工具
- `dev/tools/content_import_cards.py` - 新增 5 种操作
- `dev/tools/content_import_relics.py` - 新字段白名单

## 新增卡牌（10 张）

| 名称 | 费用 | 类型 | 效果 |
|------|------|------|------|
| 爆发 | 1 | 能力 | 获得 2 层力量 |
| 极限突破 | 2 | 能力 | 获得 1 力量；本回合伤害翻倍；消耗 |
| 战意积蓄 | 1 | 能力 | 获得 2 力量；消耗 |
| 连斩 | 1 | 攻击 | 造成 3×3 伤害 |
| 旋身击 | 1 | 攻击 | 4 伤害 + 抽 1 张牌 |
| 连环重击 | 2 | 攻击 | 5 伤害×(1+力量层，最多 3 次) |
| 风暴斩 | 0 | 攻击 | 对所有敌人造成 2 伤害 |
| 背水狂攻 | 1 | 攻击 | 6 伤害；HP≤50%时翻倍 |
| 血誓打击 | 1 | 攻击 | 失去 3 HP，造成 12 伤害 |
| 生存本能 | 1 | 技能 | 获得缺失 HP 20% 格挡 |

## 新增遗物（2 个）

| 名称 | 触发 | 效果 |
|------|------|------|
| 战怒之戒 | ON_ATTACK_PLAYED | 每打出攻击牌获得 1 力量（每战最多 5 次） |
| 淬炼石 | ON_BATTLE_START | 每场战斗开始获得 2 层力量（中途获取后下场生效） |

## 新增字段（遗物）

| 字段 | 类型 | 说明 |
|------|------|------|
| on_attack_played_strength | int | 打出攻击牌获得力量 |
| attack_play_strength_max | int | 每战触发上限 |
| on_run_start_strength | int | 每场战斗开始获得力量（兼容字段名） |

## 新增效果操作（卡牌）

| 操作 | 说明 |
|------|------|
| lose_hp | 失去HP（绕过格挡） |
| conditional_damage | 条件伤害（HP<50%翻倍） |
| strength_multiplier_damage | 力量倍率伤害 |
| missing_hp_block | 缺失HP百分比格挡 |
| damage_and_draw | 伤害+抽牌 |
| strength_and_damage_multiplier | 力量+伤害倍率 |

## 验收结果

- [x] `make test` 142/142 通过
- [x] GUT Orphan Reports = 0
- [x] 遗物内容导入工具兼容新字段
- [x] 卡牌内容导入工具兼容新操作

## 建议提交信息

```
feat(card): add 10 strength-axis cards and card UI text display (phase9)

- Phase 9-0: Fix relic tooltip description display
- Phase 9-1: Replace card icon with name + effect text
- Phase 9-2: Add 10 strength burst axis cards
- Phase 9-3: Add Rage Ring and Tempering Stone relics
- Add new effect types: lose_hp, conditional_damage, etc.
- Add relic fields: on_attack_played_strength, on_run_start_strength

Tests: 142/142 passed
```
