# verification: chore-effect-debug-gates-v1

## 自动验证
- 命令：`make test`
- 结果：通过（66/66）

## 代码核验
1. `_print_debug()` 在开关关闭时仅更新状态，不再 `push_warning`。
2. `ReproLog.log_effect()` 与 `_emit()` 在开关关闭时不输出 warning。
