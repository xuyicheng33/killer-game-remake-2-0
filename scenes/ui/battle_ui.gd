class_name BattleUI
extends CanvasLayer

const CARD_ZONES_MODEL_SCRIPT := preload("res://modules/card_system/card_zones_model.gd")

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var hand: Hand = $Hand
@onready var mana_ui: ManaUI = $ManaUI
@onready var end_turn_button: Button = %EndTurnButton

var _card_zones_model: CardZonesModel
var _zone_counts_label: Label


func _ready() -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	_card_zones_model = CARD_ZONES_MODEL_SCRIPT.get_instance()
	if not _card_zones_model.zone_counts_changed.is_connected(_on_zone_counts_changed):
		_card_zones_model.zone_counts_changed.connect(_on_zone_counts_changed)
	_setup_zone_counts_ui()
	_bind_card_zones_context()


func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	mana_ui.char_stats = char_stats
	hand.char_stats = char_stats
	_bind_card_zones_context()


func _on_player_hand_drawn() -> void:
	end_turn_button.disabled = false


func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.player_turn_ended.emit()


func _setup_zone_counts_ui() -> void:
	if _zone_counts_label != null and is_instance_valid(_zone_counts_label):
		return

	_zone_counts_label = Label.new()
	_zone_counts_label.name = "ZoneCountsLabel"
	_zone_counts_label.anchor_left = 1.0
	_zone_counts_label.anchor_top = 0.0
	_zone_counts_label.anchor_right = 1.0
	_zone_counts_label.anchor_bottom = 0.0
	_zone_counts_label.offset_left = -520.0
	_zone_counts_label.offset_top = 26.0
	_zone_counts_label.offset_right = -20.0
	_zone_counts_label.offset_bottom = 94.0
	_zone_counts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_zone_counts_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_zone_counts_label.add_theme_font_size_override("font_size", 20)
	_zone_counts_label.add_theme_color_override("font_color", Color("dbe3f2"))
	_zone_counts_label.text = "抽牌堆：0  手牌：0\n弃牌堆：0  消耗堆：0"
	add_child(_zone_counts_label)


func _bind_card_zones_context() -> void:
	if not is_node_ready():
		return
	if char_stats == null:
		return
	if _card_zones_model == null:
		return

	_card_zones_model.bind_context(char_stats, hand)
	var counts: Dictionary = _card_zones_model.get_zone_counts()
	_update_zone_counts_text(
		int(counts.get("draw", 0)),
		int(counts.get("hand", 0)),
		int(counts.get("discard", 0)),
		int(counts.get("exhaust", 0))
	)


func _on_zone_counts_changed(draw_count: int, hand_count: int, discard_count: int, exhaust_count: int) -> void:
	_update_zone_counts_text(draw_count, hand_count, discard_count, exhaust_count)


func _update_zone_counts_text(draw_count: int, hand_count: int, discard_count: int, exhaust_count: int) -> void:
	if _zone_counts_label == null or not is_instance_valid(_zone_counts_label):
		return

	_zone_counts_label.text = "抽牌堆：%d  手牌：%d\n弃牌堆：%d  消耗堆：%d" % [
		draw_count,
		hand_count,
		discard_count,
		exhaust_count,
	]
