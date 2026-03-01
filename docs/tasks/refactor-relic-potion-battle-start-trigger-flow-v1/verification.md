# Verification

## 执行命令
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test-effects-matrix`
- `TASK_ID=refactor-relic-potion-battle-start-trigger-flow-v1 bash dev/tools/workflow_check.sh`
- Godot MCP：
  - `mcp__godot__run_project`（`scene=res://runtime/scenes/app/app.tscn`）
  - `mcp__godot__get_debug_output`
  - `mcp__godot__stop_project`

## 结果
- `test_relic_potion.gd`：通过（30/30）。
- `make test-effects-matrix`：通过（`card_matrix/relic_matrix/potion_matrix` 全通过）。
- `workflow_check`：失败，原因为当前分支名 `fix/run_flow-fix-encounter-and-battle-potion-gating-v1` 不包含当前 TASK_ID（非代码逻辑失败）。
- MCP 运行态验证：`errors=[]`，`finalErrors=[]`。
