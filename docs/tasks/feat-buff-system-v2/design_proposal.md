# 设计提案：feat-buff-system-v2

**任务ID**: `feat-buff-system-v2`
**提案日期**: 2026-02-18

---

## 目标效果

扩展 BuffSystem 支持10种状态，完整实现状态触发逻辑。

---

## 非目标

- 不修改 UI 层显示逻辑（状态标签通过 `_get_status_label` 扩展）
- 不修改存档结构

---

## 方案

### 新增状态常量

```gdscript
const STATUS_BURN := "burn"
const STATUS_CONSTRICTED := "constricted"
const STATUS_METALLICIZE := "metallicize"
const STATUS_RITUAL := "ritual"
const STATUS_REGENERATE := "regenerate"

const STATUS_ORDER: Array[String] = [
    STATUS_STRENGTH,
    STATUS_DEXTERITY,
    STATUS_VULNERABLE,
    STATUS_WEAK,
    STATUS_POISON,
    STATUS_BURN,
    STATUS_CONSTRICTED,
    STATUS_METALLICIZE,
    STATUS_RITUAL,
    STATUS_REGENERATE,
]
```

### 回合开始钩子扩展

```gdscript
func _run_turn_start_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return
    
    # Regenerate: 回合开始回血=层数，层数-1
    var regen_stacks := get_status_stack(stats, STATUS_REGENERATE)
    if regen_stacks > 0:
        stats.health = mini(stats.health + regen_stacks, stats.max_health)
        _decay_status(stats, STATUS_REGENERATE)
```

### 回合结束钩子扩展

```gdscript
func _run_turn_end_hooks(target: Node) -> void:
    var stats: Stats = _extract_stats(target)
    if stats == null:
        return

    # 原有逻辑
    _trigger_poison(target, stats)
    _decay_status(stats, STATUS_WEAK)
    _decay_status(stats, STATUS_VULNERABLE)
    
    # Burn: 回合结束扣2血，然后消除
    var burn_stacks := get_status_stack(stats, STATUS_BURN)
    if burn_stacks > 0:
        stats.health -= 2
        stats.set_status(STATUS_BURN, 0)
    
    # Constricted: 回合结束扣血=层数
    var constricted_stacks := get_status_stack(stats, STATUS_CONSTRICTED)
    if constricted_stacks > 0:
        stats.health -= constricted_stacks
    
    # Metallicize: 回合结束获得格挡=层数
    var metallicize_stacks := get_status_stack(stats, STATUS_METALLICIZE)
    if metallicize_stacks > 0:
        stats.block += metallicize_stacks
    
    # Ritual: 回合结束+力量=层数
    var ritual_stacks := get_status_stack(stats, STATUS_RITUAL)
    if ritual_stacks > 0:
        stats.add_status(STATUS_STRENGTH, ritual_stacks)
```

### 状态标签扩展

```gdscript
func _get_status_label(status_id: String) -> String:
    match status_id:
        STATUS_STRENGTH: return "力"
        STATUS_DEXTERITY: return "敏"
        STATUS_VULNERABLE: return "易"
        STATUS_WEAK: return "弱"
        STATUS_POISON: return "毒"
        STATUS_BURN: return "燃"
        STATUS_CONSTRICTED: return "缚"
        STATUS_METALLICIZE: return "金"
        STATUS_RITUAL: return "怒"
        STATUS_REGENERATE: return "再"
        _: return "?"
```

---

## 触发顺序

回合结束时的触发顺序（影响生存）：
1. Poison 扣血 + 递减
2. Burn 扣血 + 消除
3. Constricted 扣血
4. Weak/Vulnerable 递减
5. Metallicize 获得格挡
6. Ritual 获得力量

---

## 对现有逻辑的影响

1. **调用点**: 无变化，状态通过 `apply_status_to_target` 施加
2. **存档**: 无影响（状态存储在 Stats 中，已有通用接口）
3. **种子一致性**: 无影响

---

## 测试计划

| 测试用例 | 验证内容 |
|---|---|
| `test_poison_decrements_each_turn()` | Poison 回合开始扣血并递减 |
| `test_weak_reduces_damage_by_25_percent()` | 虚弱减少伤害 |
| `test_vulnerable_increases_received_damage()` | 易伤增加受伤 |
| `test_strength_adds_to_attack_damage()` | 力量增加攻击伤害 |
| `test_metallicize_grants_block_on_turn_end()` | 金属化回合结束获得格挡 |
| `test_burn_deals_damage_and_removes()` | 燃烧扣血后消除 |
| `test_ritual_adds_strength_on_turn_end()` | 愤怒回合结束获得力量 |
| `test_regenrate_heals_and_decrements()` | 再生回血后递减 |

---

## 请求批准

请确认是否批准此设计方案。
