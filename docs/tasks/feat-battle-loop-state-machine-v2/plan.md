# 任务规划：feat-battle-loop-state-machine-v2

**任务ID**: `feat-battle-loop-state-machine-v2`
**任务级别**: L2
**创建日期**: 2026-02-18
**执行人**: 程序员

---

## 目标

完整实现 BattleLoop 状态机，包括：
1. PhaseStateMachine 的 enter/exit 方法
2. 阶段切换信号广播
3. 胜利/失败检测集中在 RESOLVE_PHASE

---

## 边界

**白名单**:
- `runtime/modules/battle_loop/`
- `dev/tests/unit/test_battle_context.gd`

**前置**: feat-buff-system-v2 完成

## 白名单文件

- `runtime/modules/battle_loop/`
- `dev/tests/unit/test_battle_context.gd`

---

## 阶段定义

```
DRAW_PHASE
  ├─ 抽牌（默认5张）
  ├─ 触发 _run_turn_start_hooks
  └─ → ACTION_PHASE

ACTION_PHASE
  ├─ 玩家出牌（消耗能量）
  ├─ 玩家使用药水
  └─ 玩家点击"结束回合" → ENEMY_PHASE

ENEMY_PHASE
  ├─ 所有敌人按意图行动
  ├─ 触发敌方回合钩子
  └─ → RESOLVE_PHASE

RESOLVE_PHASE
  ├─ 弃置手牌（保留牌除外）
  ├─ 触发 _run_turn_end_hooks
  ├─ 检查胜负条件
  └─ 若未结束 → DRAW_PHASE
```

---

## 步骤

### Step 1: 扩展 PhaseStateMachine
- 每个阶段添加 `enter()` / `exit()` 方法
- 添加阶段切换信号广播

### Step 2: 实现阶段逻辑
- DrawPhase: 抽牌逻辑
- ActionPhase: 玩家行动窗口
- EnemyPhase: 敌人行动
- ResolvePhase: 结算与胜负检测

### Step 3: 补充 GUT 测试
- `test_phase_transitions_in_correct_order()`
- `test_buffs_triggered_at_correct_phase()`
- `test_battle_ends_when_player_hp_reaches_zero()`

---

## 验收标准

- [ ] 状态机完整实现
- [ ] GUT 测试全部通过
- [ ] 手动验证：完整一场战斗

---

## 前置检查（1.6 门禁）

- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录
- [ ] 审核员确认可编码
