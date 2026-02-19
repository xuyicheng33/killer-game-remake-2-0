# 设计提案

## 任务 ID
`feat-potion-direct-damage-effect-v1`

## 目标

- 新增药水效果类型：对全体敌人造成固定伤害
- 使“爆炸药水”语义可真实落地

## 非目标

- 不改药水背包容量规则
- 不改商店价格规则

## 方案 A（推荐）

1. 扩展 `PotionData.EffectType`：新增 `DAMAGE_ALL_ENEMIES`
2. 在 `RelicPotionSystem` 增加该类型处理：
   - 查找 `enemies` group
   - 对每个敌人执行 `DamageEffect`
3. 更新内容资源 `storm_bomb_potion`：
   - `effect_type = DAMAGE_ALL_ENEMIES`
   - `value = 10`
4. 增加测试：
   - 多敌场景伤害生效
   - 无敌目标时安全返回

优点：
- 语义直接、数据可读性高
- 可复用于后续伤害药水

缺点：
- 需变更枚举与执行逻辑

## 方案 B

- 继续用 `BLOCK`/`GOLD` 等既有类型近似表达

缺点：
- 与需求不一致，审核不可通过

## 对存档与种子影响

- 存档：药水 `effect_type` 新枚举值需兼容旧档
- 种子一致性：不改随机逻辑

## 验收建议

- 爆炸药水可对全体敌人造成固定伤害
- 既有 `HEAL/GOLD/BLOCK` 药水行为不回归
