# 设计提案（内容填充简化）

## 任务 ID
`content-potions-set2-v1`

## 目标效果
- 药水数量达到 5。
- 新增第 5 个药水内容资源。

## 非目标
- 不改动药水使用主流程。

## 方案
- 方案 A（采用）：新增 `storm_bomb_potion` 资源，并联动 `feat-potion-direct-damage-effect-v1` 落地 `DAMAGE_ALL_ENEMIES` 执行链。
- 方案 B（不采用）：沿用 `BLOCK` 近似表达；会导致语义验收失败。

## 兼容性影响
- 存档：无结构变化。
- 种子一致性：不改 RNG 算法。
