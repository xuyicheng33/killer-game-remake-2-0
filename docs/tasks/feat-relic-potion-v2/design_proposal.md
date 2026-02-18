# 设计提案：feat-relic-potion-v2

**任务ID**: `feat-relic-potion-v2`
**提案日期**: 2026-02-18

---

## 目标效果

标准化遗物/药水触发系统：
1. 定义统一的触发时机枚举
2. 实现 RelicBase 基类接口
3. 实现 RelicRegistry 注册制管理
4. 遗物效果通过 EffectStack 派发

---

## 非目标（不做什么）

- 不修改现有遗物的数据结构（RelicData）
- 不修改 UI 显示逻辑
- 不引入新的存档字段
- 不修改药水的使用流程

---

## 方案 A（推荐）

### 触发时机枚举

```gdscript
enum TriggerType {
    ON_BATTLE_START,
    ON_TURN_START,
    ON_TURN_END,
    ON_CARD_PLAYED,
    ON_ATTACK_PLAYED,
    ON_SKILL_PLAYED,
    ON_DAMAGE_TAKEN,
    ON_BLOCK_APPLIED,
    ON_ENEMY_KILLED,
    ON_RUN_START,
    ON_SHOP_ENTER,
    ON_BOSS_KILLED,
}
```

### RelicBase 接口

```gdscript
class_name RelicBase
extends Resource

func on_trigger(trigger_type: TriggerType, context: Dictionary) -> Array[Dictionary]:
    return []
```

### 效果派发

遗物效果返回 EffectStack 格式：
```gdscript
return [
    {"type": "heal", "value": 5},
    {"type": "add_gold", "value": 10},
]
```

---

## 方案 B（备选）

不引入 RelicBase，直接在 RelicData 中添加回调函数。

**权衡**:
- 方案 A 优点：类型安全，支持复杂遗物逻辑
- 方案 B 优点：改动小，复用现有 RelicData

**选择方案 A 原因**: 符合 12.7 扩展接口规范，支持注册即生效。

---

## 对现有逻辑的影响

| 影响项 | 说明 |
|---|---|
| RelicPotionSystem | 需要重构，使用触发枚举派发 |
| RelicData | 可保留现有字段，作为简化配置 |
| 战斗流程 | 无影响（通过信号触发） |

---

## 对存档的影响

无影响。遗物列表仍存储在 RunState.relics 中。

---

## 对种子一致性的影响

无影响。触发时机由游戏事件决定，不涉及随机数。

---

## 测试计划

| 测试用例 | 验证内容 |
|---|---|
| `test_relic_fires_on_correct_trigger_event()` | 遗物在正确时机触发 |
| `test_potion_applies_effect_via_effect_stack()` | 药水效果通过 EffectStack 执行 |

---

## 请求批准

请确认是否批准此设计方案，以便进入编码阶段。
