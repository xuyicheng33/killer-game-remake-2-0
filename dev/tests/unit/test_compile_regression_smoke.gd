extends GutTest

const MAP_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/map_ui_view_model.gd")
const STATS_UI_SCRIPT := preload("res://runtime/scenes/ui/stats_ui.gd")
const BATTLE_CONTEXT_SCRIPT := preload("res://runtime/modules/battle_loop/battle_context.gd")
const ENEMY_INTENT_RULES_SCRIPT := preload("res://runtime/modules/enemy_intent/intent_rules.gd")
const ENEMY_ACTION_PICKER_SCRIPT := preload("res://runtime/scenes/enemy/enemy_action_picker.gd")
const BUFF_SYSTEM_SCRIPT := preload("res://runtime/modules/buff_system/buff_system.gd")


func test_recent_helper_refactors_compile_in_headless_environment() -> void:
	assert_not_null(MAP_UI_VIEW_MODEL_SCRIPT.new())
	assert_not_null(STATS_UI_SCRIPT.new())
	assert_not_null(BATTLE_CONTEXT_SCRIPT.new())
	assert_not_null(ENEMY_INTENT_RULES_SCRIPT.new())
	assert_not_null(ENEMY_ACTION_PICKER_SCRIPT.new())
	assert_not_null(BUFF_SYSTEM_SCRIPT.new())
