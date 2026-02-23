# Handoff

## 变更摘要
- 新增 `EffectEnqueueHelper` 统一效果入栈逻辑，并补充对 `get_effect_stack()` / `effect_stack` 属性两种上下文取栈兼容。
- 将以下效果脚本的重复 `enqueue_effect` 模板改为 helper 调用：
  - `DamageEffect`
  - `BlockEffect`
  - `ConditionalDamageEffect`
  - `DrawCardEffect`
  - `GainEnergyEffect`
- 补强 `LoseHpEffect`：
  - 自损目标优先通过 `BattleContext.get_player()` 获取（兼容 battle context 场景）。
  - stats 提取改为 `Player/Enemy/Variant` 兼容分支，避免弱类型读取异常。

## 改动文件
- `runtime/modules/effect_engine/effect_enqueue_helper.gd`
- `content/effects/damage_effect.gd`
- `content/effects/block_effect.gd`
- `content/effects/conditional_damage_effect.gd`
- `content/effects/draw_card_effect.gd`
- `content/effects/gain_energy_effect.gd`
- `content/effects/lose_hp_effect.gd`
- `docs/tasks/refactor-effect-engine-enqueue-helper-v1/plan.md`
- `docs/tasks/refactor-effect-engine-enqueue-helper-v1/handoff.md`
- `docs/tasks/refactor-effect-engine-enqueue-helper-v1/verification.md`

## 风险
- 当前 helper 主要聚焦“取栈 + 入栈模板”去重；若后续 effect 对 `priority/effect_type/source/value` 有更多特化，需防止 helper 参数膨胀。
- `workflow_check` 未通过分支命名门禁（见 verification），建议后续切换到含当前 TASK_ID 的分支继续推进。

## 建议下一步
- 将其余仍手写入栈模板的 effect 脚本继续收口到 helper，形成统一风格并减少回归面。
