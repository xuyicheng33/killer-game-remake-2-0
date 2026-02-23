# Plan

- Task ID: `refactor-app-route-dispatch-slimming-v1`
- 主模块：`run_flow`（入口场景编排瘦身）
- 目标：降低 `runtime/scenes/app/app.gd` 重复分支与样板代码，保持行为不变。

## 白名单改动
- `runtime/scenes/app/app.gd`
- `docs/tasks/refactor-app-route-dispatch-slimming-v1/{plan,handoff,verification}.md`

## 核心变更
- 用 `_route_handlers` 取代 `_dispatch_next_route` 的长 `match`。
- 新增 `_reset_app_overlay_state` 统一复位逻辑。
- 新增 `_open_run_state_screen` 收敛 rest/shop/event 三类页面的重复打开逻辑。

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_battle_flow.gd 240`
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_full_run_autoplay.gd 240`
- `make test`
