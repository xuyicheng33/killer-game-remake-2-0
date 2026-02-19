# 设计复核

## 任务 ID
`feat-card-draw-energy-ops-v1`

## 当前实现位置（文件 + 关键点）

- `dev/tools/content_import_cards.py`
  - `EFFECT_OPS` 仅允许 `damage/block/apply_status`
  - 生成模板 `func apply_effects(...)` 仅生成三类效果实例
- `content/effects/`
  - 仅存在 `DamageEffect`、`BlockEffect`、`ApplyStatusEffect`
- `content/custom_resources/card.gd`
  - `play()` 已支持透传 `battle_context`，可作为扩展入口
- `runtime/scenes/player/player_handler.gd`
  - 已有 `draw_card/draw_cards` 能力，可复用
- `content/custom_resources/character_stats.gd`
  - `mana/max_mana` 已有，可复用“回能量”写入

## 当前数据结构与限制

- 卡牌数据源允许字段：`id/name/type/rarity/cost/target/text/effects`
- `effects[].op` 当前不支持 `draw`、`energy`
- 现状导致：
  - 3b 技能分布要求中的“抽牌/回能量”无法语义落地
  - 只能通过改文案规避误导，无法达标

## 可复用点

- `battle_context` 已作为参数链路存在，可承载“抽牌/回能量”服务调用
- `EffectStackEngine.EffectType` 已有 `DRAW` 枚举，可用于日志分类

## 风险点

- 若直接改导入模板，可能影响所有自动生成卡脚本
- 若通过 `battle_context` 调用抽牌，需确认出牌窗口与动画时序
- 回能量需约束上限（`max_mana`）并避免与 X 费逻辑冲突
