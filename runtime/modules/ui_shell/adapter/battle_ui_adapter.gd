class_name BattleUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)
signal end_turn_button_enabled_changed(enabled: bool)

const CARD_ZONES_MODEL_SCRIPT := preload("res://runtime/modules/card_system/card_zones_model.gd")
const BATTLE_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/battle_ui_view_model.gd")

var _card_zones_model: CardZonesModel
var _view_model: BattleUIViewModel = BATTLE_UI_VIEW_MODEL_SCRIPT.new() as BattleUIViewModel


func _init() -> void:
	_card_zones_model = CARD_ZONES_MODEL_SCRIPT.get_instance()
	if not _card_zones_model.zone_counts_changed.is_connected(_on_zone_counts_changed):
		_card_zones_model.zone_counts_changed.connect(_on_zone_counts_changed)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)


func bind_context(char_stats: CharacterStats, hand: Hand) -> void:
	_card_zones_model.bind_context(char_stats, hand)
	var counts: Dictionary = _card_zones_model.get_zone_counts()
	var projection := _view_model.project_zone_counts(
		int(counts.get("draw", 0)),
		int(counts.get("hand", 0)),
		int(counts.get("discard", 0)),
		int(counts.get("exhaust", 0))
	)
	projection_changed.emit(projection)


func request_end_turn() -> void:
	end_turn_button_enabled_changed.emit(false)
	Events.player_turn_ended.emit()


func _on_zone_counts_changed(draw_count: int, hand_count: int, discard_count: int, exhaust_count: int) -> void:
	var projection := _view_model.project_zone_counts(draw_count, hand_count, discard_count, exhaust_count)
	projection_changed.emit(projection)


func _on_player_hand_drawn() -> void:
	end_turn_button_enabled_changed.emit(true)
