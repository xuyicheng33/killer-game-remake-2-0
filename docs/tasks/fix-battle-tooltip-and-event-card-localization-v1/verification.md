# Verification

## 执行命令
- `make test`
- `make test-effects-matrix`
- `TASK_ID=fix-battle-tooltip-and-event-card-localization-v1 bash dev/tools/workflow_check.sh`
- Godot MCP：
  - `mcp__godot__run_project`（`scene=res://runtime/scenes/app/app.tscn`）
  - `mcp__godot__get_debug_output`
  - `mcp__godot__stop_project`

## 结果
- `make test`：通过（165/165，新增 `test_event_service.gd` 4 用例通过）。
- `make test-effects-matrix`：通过（`card_matrix/relic_matrix/potion_matrix` 全通过）。
- `workflow_check`：失败，原因为当前分支名 `fix/run_flow-fix-encounter-and-battle-potion-gating-v1` 不包含当前 TASK_ID（非代码逻辑失败）。
- MCP 运行态验证：`errors=[]`，`finalErrors=[]`。
