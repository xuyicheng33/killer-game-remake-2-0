# Handoff: fix-enemy-kill-immediate-victory-v1

## 交付摘要

修复了击杀敌人后战斗不立即结束的问题。现在敌人死亡后会立即检查战斗结束条件，DOT 击杀也能正确触发胜利/失败判定。

## 改动文件

- `runtime/scenes/battle/battle.gd`
  - `_on_enemy_died()`: 新增立即调用 `check_battle_end()`
  - `_on_player_died()`: 简化为立即调用 `_on_battle_ended("defeat")`
- `dev/tests/unit/test_battle_context.gd`
  - 新增 3 个测试函数

## 风险说明

- 此修改改变了战斗结束的时序，从 RESOLVE 阶段末尾改为死亡信号发射时
- 如果有依赖原时序的逻辑（如死亡后仍有行动），需要调整

## 测试覆盖

- `test_killing_all_enemies_triggers_immediate_victory()`
- `test_player_death_triggers_immediate_defeat()`
- `test_battle_continues_when_enemies_alive()`

## 建议提交信息

`fix(battle): immediate victory/defeat check on death（fix-enemy-kill-immediate-victory-v1）`
