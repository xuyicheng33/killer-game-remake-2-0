# 任务规划：feat-reward-economy-v2

**任务ID**: `feat-reward-economy-v2`
**任务级别**: L2
**创建日期**: 2026-02-18
**执行人**: 程序员

---

## 目标

扩展商店系统，支持遗物和药水购买。

---

## 边界

**白名单**:
- `runtime/modules/reward_economy/`
- `runtime/modules/run_flow/`
- `runtime/modules/run_meta/run_state.gd`

**前置**: feat-relic-potion-v2 完成

## 白名单文件

- `runtime/modules/reward_economy/`
- `runtime/modules/run_flow/`
- `runtime/modules/run_meta/`
- `dev/tests/unit/test_reward_economy.gd`

---

## 新增功能

1. **遗物购买**: 商店生成1-2个遗物报价，价格100-300金币
2. **药水购买**: 商店生成1-2个药水报价，价格50金币
3. **商店库存**: 3张卡 + 1个遗物 + 1个药水

---

## 步骤

### Step 1: 扩展 ShopOfferGenerator
### Step 2: 实现遗物购买逻辑
### Step 3: 实现药水购买逻辑
### Step 4: 补充 GUT 测试

---

## 前置检查（1.6 门禁）

- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录
- [ ] 审核员确认可编码
