# 任务规划：feat-relic-potion-v2

**任务ID**: `feat-relic-potion-v2`
**任务级别**: L2
**创建日期**: 2026-02-18
**执行人**: 程序员

---

## 目标

完整实现遗物/药水触发系统，支持多种触发时机。

---

## 边界

**白名单**:
- `runtime/modules/relic_potion/`

**前置**: feat-buff-system-v2 完成

---

## 遗物触发时机枚举

| 常量名 | 触发时机 |
|---|---|
| ON_BATTLE_START | 每次战斗开始 |
| ON_TURN_START | 玩家回合开始 |
| ON_TURN_END | 玩家回合结束 |
| ON_CARD_PLAYED | 打出一张牌 |
| ON_ATTACK_PLAYED | 打出攻击牌 |
| ON_SKILL_PLAYED | 打出技能牌 |
| ON_DAMAGE_TAKEN | 玩家受伤 |
| ON_BLOCK_APPLIED | 玩家获得格挡 |
| ON_ENEMY_KILLED | 击杀一个敌人 |
| ON_RUN_START | 开局 |
| ON_SHOP_ENTER | 进入商店 |
| ON_BOSS_KILLED | 击杀Boss |

---

## 步骤

### Step 1: 定义触发时机枚举
### Step 2: 实现 RelicBase 基类
### Step 3: 实现 RelicRegistry
### Step 4: 遗物效果通过 EffectStack 派发
### Step 5: 补充 GUT 测试

---

## 前置检查（1.6 门禁）

- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录
- [ ] 审核员确认可编码
