# plan: fix-type-safety-v1

## 目标
- 清理高风险 `as` 类型转换（`Dictionary.get/load/get_child` 直接转换）。
- 增加自动门禁，阻止同类问题回归。

## 白名单说明（门禁例外）
- `.new() as ClassName`
- `.instantiate() as ClassName`
- `.duplicate(...) as ClassName`
- 已有 `typeof/is` 判定后再转换

## 变更边界
- `runtime/global/run_rng.gd`
- `runtime/scenes/enemy/enemy_handler.gd`
- `runtime/scenes/app/app.gd`
- `runtime/modules/run_flow/run_lifecycle_service.gd`
- `runtime/modules/run_flow/shop_flow_service.gd`
- `runtime/modules/reward_economy/reward_generator.gd`
- `runtime/modules/persistence/save_service.gd`
- `runtime/modules/map_event/map_graph_data.gd`
- `runtime/modules/relic_potion/relic_catalog.gd`
- `runtime/modules/relic_potion/potion_catalog.gd`
- `runtime/modules/enemy_intent/enemy_registry.gd`
- `runtime/modules/run_meta/character_registry.gd`
- `runtime/modules/map_event/event_service.gd`
- `runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd`
- `runtime/modules/ui_shell/viewmodel/event_ui_view_model.gd`
- `dev/tools/type_safety_check.sh`
- `dev/tools/workflow_check.sh`
- `Makefile`

## 验收标准
- `bash dev/tools/type_safety_check.sh` 通过。
- `make test` 通过。
