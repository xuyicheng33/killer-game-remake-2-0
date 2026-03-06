class_name RelicPotionUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)

const RELIC_POTION_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd")

var _run_state: RunState
var _relic_potion_system: RelicPotionSystem
var _latest_log := ""
var _view_model: RelicPotionViewModel = RELIC_POTION_VIEW_MODEL_SCRIPT.new() as RelicPotionViewModel


func set_run_state(value: RunState) -> void:
	_run_state = value
	refresh()


func set_relic_potion_system(value: RelicPotionSystem) -> void:
	if _relic_potion_system:
		if _relic_potion_system.log_updated.is_connected(_on_log_updated):
			_relic_potion_system.log_updated.disconnect(_on_log_updated)
		if _relic_potion_system.battle_state_changed.is_connected(_on_battle_state_changed):
			_relic_potion_system.battle_state_changed.disconnect(_on_battle_state_changed)

	_relic_potion_system = value
	if _relic_potion_system:
		if not _relic_potion_system.log_updated.is_connected(_on_log_updated):
			_relic_potion_system.log_updated.connect(_on_log_updated)
		if not _relic_potion_system.battle_state_changed.is_connected(_on_battle_state_changed):
			_relic_potion_system.battle_state_changed.connect(_on_battle_state_changed)
	refresh()


func use_potion(index: int) -> void:
	if _relic_potion_system == null:
		return
	_relic_potion_system.use_potion(index)
	refresh()


func is_battle_active() -> bool:
	return _relic_potion_system != null and _relic_potion_system.is_battle_active()


func refresh() -> void:
	var projection := _view_model.project(_run_state, _latest_log)
	var battle_active := is_battle_active()
	var battle_projection_variant: Variant = projection.get("battle_projection", {})
	if battle_projection_variant is Dictionary:
		var battle_projection: Dictionary = (battle_projection_variant as Dictionary).duplicate(true)
		var raw_buttons: Variant = battle_projection.get("potion_buttons", [])
		var buttons_with_state: Array[Dictionary] = []
		if raw_buttons is Array:
			for button_variant in raw_buttons:
				if not (button_variant is Dictionary):
					continue
				var button_data: Dictionary = (button_variant as Dictionary).duplicate(true)
				button_data["enabled"] = battle_active
				buttons_with_state.append(button_data)
		battle_projection["potion_buttons"] = buttons_with_state
		battle_projection["battle_only_hint_visible"] = not battle_active and not buttons_with_state.is_empty()
		projection["battle_projection"] = battle_projection
	projection["battle_active"] = battle_active
	projection_changed.emit(projection)


func _on_log_updated(text: String) -> void:
	_latest_log = text
	refresh()


func _on_battle_state_changed(_active: bool) -> void:
	refresh()
