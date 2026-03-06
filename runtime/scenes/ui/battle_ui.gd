class_name BattleUI
extends CanvasLayer

const BATTLE_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/battle_ui_adapter.gd")

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var hand: Hand = $Hand
@onready var mana_ui: ManaUI = $ManaUI
@onready var end_turn_button: Button = %EndTurnButton
@onready var hand_container: HBoxContainer = $Hand

var _adapter: BattleUIAdapter
var _zone_counts_label: Label
var _battle_context: RefCounted


func _ready() -> void:
	_adapter = BATTLE_UI_ADAPTER_SCRIPT.new() as BattleUIAdapter
	_connect_signals()
	_setup_zone_counts_ui()
	_bind_context()

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)


func _exit_tree() -> void:
	_disconnect_signals()

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if _adapter != null:
		_adapter.dispose()
		_adapter = null


func _connect_signals() -> void:
	if _adapter != null:
		if not _adapter.projection_changed.is_connected(_on_projection_changed):
			_adapter.projection_changed.connect(_on_projection_changed)
		if not _adapter.end_turn_button_enabled_changed.is_connected(_on_end_turn_button_enabled_changed):
			_adapter.end_turn_button_enabled_changed.connect(_on_end_turn_button_enabled_changed)
	if not end_turn_button.pressed.is_connected(_on_end_turn_button_pressed):
		end_turn_button.pressed.connect(_on_end_turn_button_pressed)


func _disconnect_signals() -> void:
	if _adapter != null:
		if _adapter.projection_changed.is_connected(_on_projection_changed):
			_adapter.projection_changed.disconnect(_on_projection_changed)
		if _adapter.end_turn_button_enabled_changed.is_connected(_on_end_turn_button_enabled_changed):
			_adapter.end_turn_button_enabled_changed.disconnect(_on_end_turn_button_enabled_changed)
	if end_turn_button.pressed.is_connected(_on_end_turn_button_pressed):
		end_turn_button.pressed.disconnect(_on_end_turn_button_pressed)


func bind_battle_context(battle_context: BattleContext) -> void:
	_battle_context = battle_context
	hand.battle_context = battle_context
	if _adapter != null:
		_adapter.bind_battle_context(battle_context)
	_bind_context()


func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	mana_ui.char_stats = char_stats
	hand.char_stats = char_stats
	_bind_context()


func _on_projection_changed(projection: Dictionary) -> void:
	var text_variant: Variant = projection.get("zone_counts_text", "")
	if text_variant is String:
		_update_zone_counts_text(text_variant)


func _on_end_turn_button_enabled_changed(enabled: bool) -> void:
	end_turn_button.disabled = not enabled


func _on_end_turn_button_pressed() -> void:
	_adapter.request_end_turn()


func _setup_zone_counts_ui() -> void:
	if _zone_counts_label != null and is_instance_valid(_zone_counts_label):
		return

	_zone_counts_label = Label.new()
	_zone_counts_label.name = "ZoneCountsLabel"
	_zone_counts_label.anchor_left = 1.0
	_zone_counts_label.anchor_top = 0.0
	_zone_counts_label.anchor_right = 1.0
	_zone_counts_label.anchor_bottom = 0.0
	_zone_counts_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_zone_counts_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_zone_counts_label.add_theme_font_size_override("font_size", 20)
	_zone_counts_label.add_theme_color_override("font_color", UIColors.ZONE_COUNTS_TEXT)
	_zone_counts_label.text = "抽牌堆：0  手牌：0\n弃牌堆：0  消耗堆：0"
	add_child(_zone_counts_label)
	_apply_zone_counts_responsive_layout()


func _apply_zone_counts_responsive_layout() -> void:
	if _zone_counts_label == null or not is_instance_valid(_zone_counts_label):
		return

	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size := viewport.get_visible_rect().size
	var label_width := clampf(viewport_size.x * 0.35, 280.0, 520.0)
	var right_margin := clampf(viewport_size.x * 0.02, 16.0, 24.0)
	var top_margin := clampf(viewport_size.y * 0.03, 20.0, 32.0)

	_zone_counts_label.offset_left = -(label_width + right_margin)
	_zone_counts_label.offset_top = top_margin
	_zone_counts_label.offset_right = -right_margin
	_zone_counts_label.offset_bottom = top_margin + 68.0


func _bind_context() -> void:
	if not is_node_ready():
		return
	if char_stats == null:
		return
	if _adapter == null:
		return
	if _battle_context == null:
		return

	_adapter.bind_context(char_stats, hand)


func _update_zone_counts_text(text: String) -> void:
	if _zone_counts_label == null or not is_instance_valid(_zone_counts_label):
		return

	_zone_counts_label.text = text


func _on_viewport_resized() -> void:
	_apply_zone_counts_responsive_layout()
