class_name RelicPotionUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)

const RELIC_POTION_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd")

var _run_state: RunState
var _relic_potion_system: RelicPotionSystem
var _latest_log := ""
var _view_model: RelicPotionViewModel = RELIC_POTION_VIEW_MODEL_SCRIPT.new() as RelicPotionViewModel


func set_run_state(value: RunState) -> void:
	if _run_state and _run_state.changed.is_connected(_on_run_state_changed):
		_run_state.changed.disconnect(_on_run_state_changed)

	_run_state = value
	if _run_state and not _run_state.changed.is_connected(_on_run_state_changed):
		_run_state.changed.connect(_on_run_state_changed)
	refresh()


func set_relic_potion_system(value: RelicPotionSystem) -> void:
	if _relic_potion_system and _relic_potion_system.log_updated.is_connected(_on_log_updated):
		_relic_potion_system.log_updated.disconnect(_on_log_updated)

	_relic_potion_system = value
	if _relic_potion_system and not _relic_potion_system.log_updated.is_connected(_on_log_updated):
		_relic_potion_system.log_updated.connect(_on_log_updated)
	refresh()


func use_potion(index: int) -> void:
	if _relic_potion_system == null:
		return
	_relic_potion_system.use_potion(index)
	refresh()


func refresh() -> void:
	var projection := _view_model.project(_run_state, _latest_log)
	var button_enabled := _relic_potion_system != null
	var raw_buttons: Variant = projection.get("potion_buttons", [])
	var buttons_with_state: Array[Dictionary] = []
	if raw_buttons is Array:
		for button_variant in raw_buttons:
			if not (button_variant is Dictionary):
				continue
			var button_data: Dictionary = (button_variant as Dictionary).duplicate(true)
			button_data["enabled"] = button_enabled
			buttons_with_state.append(button_data)
	projection["potion_buttons"] = buttons_with_state
	projection_changed.emit(projection)


func _on_run_state_changed() -> void:
	refresh()


func _on_log_updated(text: String) -> void:
	_latest_log = text
	refresh()
