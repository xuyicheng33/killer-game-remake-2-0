# enemy_intent

状态：
- Phase A / A5 `feat-enemy-intent-rules-v1`：已接入最小规则层（条件优先、不可连续、ascension 占位）。

职责：
- 提供敌人意图（下一回合动作）选择的规则层，降低 `runtime/scenes/enemy/*` 对“如何选动作”的耦合。

当前最小实现：
- `intent_rules.gd`：给定动作集合与上一动作，返回下一动作：
  - 条件动作优先于权重动作
  - 存在替代项时禁止连续动作（soft constraint）
  - `ascension_level` 作为占位参数，可从 `EnemyActionPicker` 配置
