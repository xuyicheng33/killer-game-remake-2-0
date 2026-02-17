class_name RestUIViewModel
extends RefCounted


func project(run_state: RunState) -> Dictionary:
	var projection := {
		"hp_text": "生命：--/--",
		"rest_button_disabled": true,
		"upgrade_button_disabled": true,
	}

	if run_state == null or run_state.player_stats == null:
		return projection

	projection["hp_text"] = "生命：%d/%d" % [run_state.player_stats.health, run_state.player_stats.max_health]
	projection["rest_button_disabled"] = false
	projection["upgrade_button_disabled"] = false

	return projection
