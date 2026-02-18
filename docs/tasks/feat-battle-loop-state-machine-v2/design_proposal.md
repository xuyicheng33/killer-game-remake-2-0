# 设计提案：feat-battle-loop-state-machine-v2

**任务ID**: `feat-battle-loop-state-machine-v2`
**提案日期**: 2026-02-18

---

## 目标效果

扩展 PhaseStateMachine 支持阶段行为和胜负检测：
1. 每个阶段有 `enter()` / `exit()` 方法
2. 阶段切换通过信号广播
3. 胜利/失败检测集中在 RESOLVE_PHASE

---

## 非目标（不做什么）

- 不修改战斗场景的 UI 逻辑
- 不修改存档结构
- 不引入新的信号类型（复用现有 Events.*）
- 不修改敌人 AI 行为

---

## 方案 A（推荐）

### 阶段行为接口

```gdscript
class_name PhaseState
extends RefCounted

var machine: BattlePhaseStateMachine

func enter() -> void:
    pass

func exit() -> void:
    pass
```

### 阶段实现

```gdscript
class_name DrawPhaseState
extends PhaseState

func enter() -> void:
    Events.player_hand_drawn.emit()
    machine.buff_system._run_turn_start_hooks(machine.player)
    machine.transition_to(BattlePhaseStateMachine.Phase.ACTION)
```

### 胜负检测

在 RESOLVE_PHASE 中：
```gdscript
func check_battle_end() -> Dictionary:
    if machine.player.stats.health <= 0:
        return {"ended": true, "result": "defeat"}
    if machine.enemies.is_empty():
        return {"ended": true, "result": "victory"}
    return {"ended": false}
```

---

## 方案 B（备选）

不引入 PhaseState 类，直接在 BattlePhaseStateMachine 中添加阶段回调。

**权衡**:
- 方案 A 优点：阶段逻辑解耦，易于扩展新阶段
- 方案 B 优点：实现更简单，类数量少

**选择方案 A 原因**: 符合开闭原则，后续扩展更灵活。

---

## 对现有逻辑的影响

| 影响项 | 说明 |
|---|---|
| 战斗场景 | 需要适配新的状态机接口 |
| 敌人系统 | 无影响（仍通过 Events 通信） |
| UI 层 | 无影响（仍监听 Events 信号） |

---

## 对存档的影响

无影响。状态机是运行时对象，不持久化。

---

## 对种子一致性的影响

无影响。状态转换不涉及随机数。

---

## 测试计划

| 测试用例 | 验证内容 |
|---|---|
| `test_phase_transitions_in_correct_order()` | 阶段按正确顺序转换 |
| `test_buffs_triggered_at_correct_phase()` | Buff 在正确阶段触发 |
| `test_battle_ends_when_player_hp_reaches_zero()` | 玩家死亡时战斗结束 |
| `test_battle_ends_when_all_enemies_dead()` | 敌人全灭时战斗结束 |

---

## 请求批准

请确认是否批准此设计方案，以便进入编码阶段。
