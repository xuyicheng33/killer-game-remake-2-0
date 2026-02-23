# Plan

- Task ID: `refactor-battle-loop-enemy-spawn-service-v1`
- 主模块：`battle_loop`
- 目标：将 `battle.gd` 的敌人生成逻辑下沉到模块服务，减少场景脚本职责。

## 白名单改动
- `runtime/modules/battle_loop/enemy_spawn_service.gd`
- `runtime/scenes/battle/battle.gd`
- `runtime/modules/battle_loop/README.md`
- `docs/tasks/refactor-battle-loop-enemy-spawn-service-v1/{plan,handoff,verification}.md`

## 验证
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_battle_flow.gd 240`
- `bash dev/tools/run_gut_test_file.sh res://dev/tests/integration/test_full_run_autoplay.gd 240`
- `make test`
