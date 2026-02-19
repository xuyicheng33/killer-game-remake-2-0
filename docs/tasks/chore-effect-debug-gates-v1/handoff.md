# handoff: chore-effect-debug-gates-v1

## 已完成
- `EffectStackEngine` 新增可配置调试开关：
  - ProjectSettings: `sts/debug/effect_stack_verbose`
  - Env: `STS_EFFECT_STACK_DEBUG`
- `ReproLog` 新增可配置日志开关：
  - Effect log: `sts/debug/repro_log_effect` / `STS_REPRO_LOG_EFFECT`
  - Event log: `sts/debug/repro_log_event` / `STS_REPRO_LOG_EVENT`

## 默认行为
- 未配置时默认关闭 warning 输出。
