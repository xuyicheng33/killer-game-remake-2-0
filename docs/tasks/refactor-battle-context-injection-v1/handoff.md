# handoff: refactor-battle-context-injection-v1

## 改动摘要
- 状态机改为纯相位状态，不再内部驱动战斗事件。
- 战斗场景切换为 `BattleContext.phase_machine` 唯一实例。
- 开战时补 `bind_combatants(player, enemies)`。
- 单测更新为显式相位推进并验证状态机不发 turn 事件。

## 影响
- 解决 turn-start/turn-end 双路触发风险的上游来源。
- 为后续 Buff/遗物触发一致性修复打基础。

## 后续
- 继续执行遗物触发链补齐（Task B）。
