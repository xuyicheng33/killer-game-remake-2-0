# 设计提案

## 任务 ID
`feat-card-draw-energy-ops-v1`

## 目标

- 在卡牌数据层支持 `effects.op = draw` 与 `effects.op = gain_energy`
- 让 3b 卡牌“抽牌/回能量”语义可真实执行

## 非目标

- 不改卡牌费用结算主流程
- 不改 RNG 算法
- 不做大规模平衡性重调

## 方案 A（推荐）

1. 扩展 `content_import_cards.py` 校验与模板生成：
   - 新增 `draw`：字段 `amount`
   - 新增 `gain_energy`：字段 `amount`
2. 新增可复用效果脚本：
   - `DrawCardEffect`：通过 `battle_context`/`player_handler` 执行抽牌
   - `GainEnergyEffect`：给玩家 `mana += amount`（上限 `max_mana`）
3. 更新 3b 卡牌数据：
   - 至少 1 张技能卡使用 `draw`
   - 至少 1 张技能卡使用 `gain_energy`
4. 补 GUT：
   - 导入器校验用例（新 op）
   - 抽牌/回能量执行用例

优点：
- 数据与效果一一对应，后续扩容成本低
- 不污染已有 `apply_status` 语义

缺点：
- 需要新增效果脚本与导入器变更，改动面较大

## 方案 B

- 不改导入器，继续用 `apply_status` 间接表达抽牌/回能量

缺点：
- 语义不一致，无法满足主计划验收要求

## 对存档与种子影响

- 存档结构：无强制新增字段
- 种子一致性：不新增随机源，仅复用既有抽牌流程与 RNG

## 验收建议

- 卡牌数据中出现并可通过导入器通过 `draw/gain_energy`
- 运行中实际可见“抽牌数量变化、能量变化”
- 相关 GUT 全通过
