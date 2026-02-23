# Verification

## 执行命令
- `make test-effects-matrix`
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_relic_potion.gd 240`
- `make test`
- Godot MCP：
  - `mcp__godot__run_project`
  - `mcp__godot__get_debug_output`
  - `mcp__godot__stop_project`

## 结果
- `make test-effects-matrix`：通过（card/relic/potion 三套矩阵均通过，并生成 `dev/reports/effect_matrix_report.json`）。
- `test_relic_potion.gd`：通过（30/30）。
- `make test`：通过（161/161）。
- MCP 运行态验证：`get_debug_output.errors=[]`，`finalErrors=[]`。
