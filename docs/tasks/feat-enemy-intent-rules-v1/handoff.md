# 任务交接

## 基本信息

- 任务 ID：`feat-enemy-intent-rules-v1`
- 主模块：`enemy_intent`
- 提交人：Codex
- 日期：2026-02-15

## 改动摘要

- 新增敌人意图规则层：条件动作优先、不可连续动作（soft constraint）、ascension 参数占位。
- `EnemyActionPicker` 接入规则层；`Enemy` 在动作完成时记录“上一动作”，用于下一回合禁连。
- ascension 提供 `EnemyActionPicker.ascension_level` 可配置入口（默认 0，当前不影响具体数值，仅占位）。

## 变更文件

- `docs/tasks/feat-enemy-intent-rules-v1/plan.md`
- `docs/tasks/feat-enemy-intent-rules-v1/handoff.md`
- `docs/tasks/feat-enemy-intent-rules-v1/verification.md`
- `modules/enemy_intent/intent_rules.gd`
- `modules/enemy_intent/README.md`
- `scenes/enemy/enemy_action.gd`
- `scenes/enemy/enemy_action_picker.gd`
- `scenes/enemy/enemy.gd`

## 验证结果

- [ ] 用例 1：条件动作优先于权重动作（未运行时实测；步骤见 `verification.md`）
- [ ] 用例 2：不可连续动作生效（未运行时实测；步骤见 `verification.md`）
- [ ] 边界用例：仅剩一个动作可选时兜底（未运行时实测；步骤见 `verification.md`）
- [x] `make workflow-check TASK_ID=feat-enemy-intent-rules-v1`

## 风险与影响范围

- 行为变化：对“仅两个权重动作”的敌人，开启不可连续后可能表现为强制交替（更像约束型而非纯权重分布）。
- 若未来引入确定性 RNG/回放，本模块当前仍使用全局 `randf()`（本任务不扩展到随机数体系）。

## 建议提交信息

- `feat(enemy_intent): enemy intent rules v1（feat-enemy-intent-rules-v1）`
