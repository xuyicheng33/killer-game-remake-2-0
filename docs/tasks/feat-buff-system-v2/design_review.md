# 设计复核：feat-buff-system-v2

**任务ID**: `feat-buff-system-v2`
**复核日期**: 2026-02-18

---

## 当前实现位置

**文件**: `runtime/modules/buff_system/buff_system.gd`

**关键函数**:
- `_run_turn_start_hooks(target: Node)`（第202-227行）
- `_run_turn_end_hooks(target: Node)`（第229-236行）
- `_run_after_card_played_hooks(target: Node)`（第239-261行）

---

## 当前数据结构

```gdscript
const STATUS_STRENGTH := "strength"
const STATUS_DEXTERITY := "dexterity"
const STATUS_VULNERABLE := "vulnerable"
const STATUS_WEAK := "weak"
const STATUS_POISON := "poison"

const STATUS_ORDER: Array[String] = [
    STATUS_STRENGTH,
    STATUS_DEXTERITY,
    STATUS_VULNERABLE,
    STATUS_WEAK,
    STATUS_POISON,
]
```

---

## 当前实现状态

| 状态 | 触发时机 | 实现状态 |
|---|---|---|
| 力量 | 攻击伤害加算 | ✅ 已实现（get_modified_damage） |
| 敏捷 | 格挡加算 | ✅ 已实现（get_modified_block） |
| 易伤 | 受伤+50% | ✅ 已实现（get_modified_damage） |
| 虚弱 | 攻击-25% | ✅ 已实现（get_modified_damage） |
| 中毒 | 回合开始扣血 | ✅ 已实现（_trigger_poison） |

---

## 需要扩展的内容

1. **新状态常量**: Burn, Constricted, Metallicize, Ritual, Regenerate
2. **回合开始触发**: Regenerate 回血
3. **回合结束触发**: Burn 扣血消除, Constricted 扣血, Metallicize 获得格挡, Ritual 获得力量
4. **状态标签**: 用于 UI 显示

---

## 复用点

1. `get_status_stack()` 和 `apply_status_to_stats()` 可直接复用
2. `_decay_status()` 模式可复用
3. `get_status_badges()` 可扩展新状态标签

---

## 风险点

1. **状态交互**: 多状态同时生效时的顺序（如先回血后扣血）
2. **UI 显示**: 新状态需要标签文本

---

## 结论

BuffSystem 结构清晰，可在此基础上扩展。主要改动：
1. 添加新状态常量
2. 扩展 STATUS_ORDER
3. 在对应钩子中添加新状态处理逻辑
