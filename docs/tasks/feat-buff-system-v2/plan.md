# 任务规划：feat-buff-system-v2

**任务ID**: `feat-buff-system-v2`
**任务级别**: L2
**创建日期**: 2026-02-18
**执行人**: 程序员

---

## 目标

在现有5种状态基础上扩展到10种状态，完整实现状态效果触发逻辑。

---

## 边界

**白名单**:
- `runtime/modules/buff_system/buff_system.gd`
- `dev/tests/unit/test_buff_system.gd`

**前置**: feat-effect-stack-v2 完成

## 白名单文件

- `runtime/modules/buff_system/`
- `dev/tests/unit/test_buff_system.gd`

---

## 状态扩展计划

| 状态 | 触发时机 | 层数消耗规则 | 实现位置 |
|---|---|---|---|
| 力量（Strength） | 已实现 | 永久 | 已有 |
| 敏捷（Dexterity） | 已实现 | 永久 | 已有 |
| 易伤（Vulnerable） | 已实现 | 回合结束-1 | 已有 |
| 虚弱（Weak） | 已实现 | 回合结束-1 | 已有 |
| 中毒（Poison） | 已实现 | 回合开始-1至0消除 | 已有 |
| 燃烧（Burn） | 回合结束扣2血，然后消除 | 回合结束消除 | **新增** |
| 束缚（Constricted） | 回合结束扣血=层数 | 永久 | **新增** |
| 金属化（Metallicize） | 回合结束获得格挡=层数 | 永久 | **新增** |
| 愤怒（Ritual） | 回合结束+力量=层数 | 永久 | **新增** |
| 再生（Regenerate） | 回合结束回血=层数 | 回合结束-1 | **新增** |

---

## 步骤

### Step 1: 添加新状态常量
- 在 `buff_system.gd` 中添加新状态常量

### Step 2: 实现 `_run_turn_start_hooks` 中的再生逻辑
- 回合开始时触发再生效果

### Step 3: 扩展 `_run_turn_end_hooks`
- 添加燃烧、束缚、金属化、愤怒的触发逻辑

### Step 4: 补充 GUT 测试
- `test_poison_decrements_each_turn()`
- `test_weak_reduces_damage_by_25_percent()`
- `test_vulnerable_increases_received_damage()`
- `test_strength_adds_to_attack_damage()`
- `test_metallicize_grants_block_on_turn_end()`

---

## 风险

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 状态叠加规则复杂 | 中 | 明确文档，单元测试覆盖 |

---

## 验收标准

- [ ] 10种状态全部可触发
- [ ] GUT 测试全部通过
- [ ] 手动验证：各状态效果正确

---

## 前置检查（1.6 门禁）

- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录
- [ ] 审核员确认可编码
