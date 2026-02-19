# plan: chore-effect-debug-gates-v1

## 目标
- 为 EffectStack 与 ReproLog 增加可配置调试开关。
- 默认关闭高噪声 warning，避免常态日志污染。

## 开关方案
- 优先读取 `ProjectSettings`。
- 未配置时回退读取环境变量。

## 变更边界
- `runtime/modules/effect_engine/effect_stack_engine.gd`
- `runtime/global/repro_log.gd`

## 验收标准
- 默认配置下不输出调试 warning。
- 开启开关后恢复调试输出。
- `make test` 通过。
