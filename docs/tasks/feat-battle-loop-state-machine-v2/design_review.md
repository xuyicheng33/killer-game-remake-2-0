# 设计复核：feat-battle-loop-state-machine-v2

**任务ID**: `feat-battle-loop-state-machine-v2`
**复核日期**: 2026-02-18

---

## 当前实现位置

**文件**: `runtime/modules/battle_loop/battle_phase_state_machine.gd`

**关键结构**:
```gdscript
enum Phase {
    INVALID = -1,
    DRAW,
    ACTION,
    ENEMY,
    RESOLVE,
}

signal phase_changed(from_phase: Phase, to_phase: Phase, turn: int)

func start() -> void
func can_transition(to_phase: Phase) -> bool
func transition_to(to_phase: Phase) -> bool
```

---

## 当前数据结构

状态机当前仅管理状态转换，不持有战斗上下文：
- `_phase: Phase` 当前阶段
- `_turn: int` 当前回合数

---

## 当前限制

1. **无 enter/exit 方法**: 阶段切换时无钩子
2. **无阶段逻辑**: 状态机仅管理状态，不执行逻辑
3. **无胜负检测**: 未集成战斗结束判断
4. **无上下文引用**: 无法访问 player/enemies/buff_system

---

## 复用点

1. `Phase` 枚举定义正确
2. `phase_changed` 信号可复用
3. `can_transition()` 转换规则正确

---

## 风险点

| 风险 | 影响 | 缓解措施 |
|---|---|---|
| 阶段逻辑耦合 | 中 | 使用 PhaseState 类解耦 |
| 信号时序问题 | 中 | 明确 enter/exit 触发顺序 |
| 状态机实例化 | 低 | 通过 BattleContext 注入 |

---

## 结论

状态机骨架已建立，需要：
1. 添加阶段行为接口
2. 集成现有信号（Events.*）
3. 添加胜负检测逻辑
