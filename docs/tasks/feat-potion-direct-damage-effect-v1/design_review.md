# 设计复核

## 任务 ID
`feat-potion-direct-damage-effect-v1`

## 当前实现位置（文件 + 关键点）

- `content/custom_resources/potions/potion_data.gd`
  - `EffectType` 仅 `HEAL/GOLD/BLOCK`
- `runtime/modules/relic_potion/relic_potion_system.gd`
  - `_potion_effect_type()` 与 `_apply_potion_effect()` 仅处理上述三种类型
- `content/custom_resources/potions/*.tres`
  - 新药水只能映射到已有类型，无法表达“对敌方全体伤害”

## 当前数据结构与限制

- 无法用内容字段表达 AoE 伤害药水
- 导致 `storm_bomb_potion` 只能降级为 `BLOCK` 语义

## 可复用点

- `DamageEffect` 已存在，可复用执行对敌伤害
- `RelicPotionSystem._find_player()` 与场景树 group 查询机制可扩展为敌方目标查询

## 风险点

- 需要定义“药水伤害是否受力量/易伤等修正”
- 对全体敌人时需处理空目标与死亡边界
- 需补测试避免影响现有药水行为
