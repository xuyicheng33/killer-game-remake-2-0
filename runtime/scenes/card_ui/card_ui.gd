class_name CardUI
extends Control

signal reparent_requested(which_card_ui: CardUI)

const BASE_STYLEBOX := preload("res://runtime/scenes/card_ui/card_base_stylebox.tres")
const DRAG_STYLEBOX := preload("res://runtime/scenes/card_ui/card_drag_stylebox.tres")
const HOVER_STYLEBOX := preload("res://runtime/scenes/card_ui/card_hover_stylebox.tres")

@export var card: Card : set = _set_card
@export var char_stats: CharacterStats : set = _set_char_stats

@onready var panel: Panel = $Panel
@onready var cost: Label = $Cost
@onready var name_label: Label = $CardContent/NameLabel
@onready var desc_label: Label = $CardContent/DescLabel
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var targets: Array[Node] = []

var original_index := 0
var parent: Control
var tween: Tween
var playable := true : set = _set_playable
var disabled := false
var battle_context: RefCounted


func _ready() -> void:
	_connect_signals()
	card_state_machine.init(self)


func _exit_tree() -> void:
	_disconnect_signals()
	if char_stats != null and char_stats.stats_changed.is_connected(_on_char_stats_changed):
		char_stats.stats_changed.disconnect(_on_char_stats_changed)


func _connect_signals() -> void:
	if not Events.card_aim_started.is_connected(_on_card_drag_or_aiming_started):
		Events.card_aim_started.connect(_on_card_drag_or_aiming_started)
	if not Events.card_drag_started.is_connected(_on_card_drag_or_aiming_started):
		Events.card_drag_started.connect(_on_card_drag_or_aiming_started)
	if not Events.card_drag_ended.is_connected(_on_card_drag_or_aim_ended):
		Events.card_drag_ended.connect(_on_card_drag_or_aim_ended)
	if not Events.card_aim_ended.is_connected(_on_card_drag_or_aim_ended):
		Events.card_aim_ended.connect(_on_card_drag_or_aim_ended)
	if not Events.player_hand_drawn.is_connected(_refresh_playable_state):
		Events.player_hand_drawn.connect(_refresh_playable_state)
	if not Events.player_turn_ended.is_connected(_refresh_playable_state):
		Events.player_turn_ended.connect(_refresh_playable_state)
	if not Events.player_hand_discarded.is_connected(_refresh_playable_state):
		Events.player_hand_discarded.connect(_refresh_playable_state)


func _disconnect_signals() -> void:
	if Events.card_aim_started.is_connected(_on_card_drag_or_aiming_started):
		Events.card_aim_started.disconnect(_on_card_drag_or_aiming_started)
	if Events.card_drag_started.is_connected(_on_card_drag_or_aiming_started):
		Events.card_drag_started.disconnect(_on_card_drag_or_aiming_started)
	if Events.card_drag_ended.is_connected(_on_card_drag_or_aim_ended):
		Events.card_drag_ended.disconnect(_on_card_drag_or_aim_ended)
	if Events.card_aim_ended.is_connected(_on_card_drag_or_aim_ended):
		Events.card_aim_ended.disconnect(_on_card_drag_or_aim_ended)
	if Events.player_hand_drawn.is_connected(_refresh_playable_state):
		Events.player_hand_drawn.disconnect(_refresh_playable_state)
	if Events.player_turn_ended.is_connected(_refresh_playable_state):
		Events.player_turn_ended.disconnect(_refresh_playable_state)
	if Events.player_hand_discarded.is_connected(_refresh_playable_state):
		Events.player_hand_discarded.disconnect(_refresh_playable_state)


func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)


func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)


func play() -> void:
	if not card:
		queue_free()
		return
	if char_stats == null:
		queue_free()
		return
	if not card.can_play(char_stats, battle_context):
		queue_free()
		return
	
	card.play(targets, char_stats, battle_context)
	queue_free()


func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)


func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()


func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()


func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready

	card = value
	cost.text = card.get_cost_label()
	name_label.text = card.get_display_name()
	desc_label.text = card.tooltip_text
	_refresh_playable_state()


func _set_playable(value: bool) -> void:
	playable = value
	if not playable:
		cost.add_theme_color_override("font_color", Color.RED)
		name_label.modulate = Color(1, 1, 1, 0.5)
		desc_label.modulate = Color(1, 1, 1, 0.5)
	else:
		cost.remove_theme_color_override("font_color")
		name_label.modulate = Color(1, 1, 1, 1)
		desc_label.modulate = Color(1, 1, 1, 1)


func _set_char_stats(value: CharacterStats) -> void:
	if char_stats != null and char_stats.stats_changed.is_connected(_on_char_stats_changed):
		char_stats.stats_changed.disconnect(_on_char_stats_changed)
	char_stats = value
	if char_stats != null and not char_stats.stats_changed.is_connected(_on_char_stats_changed):
		char_stats.stats_changed.connect(_on_char_stats_changed)
	_refresh_playable_state()


func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)


func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)


func _on_card_drag_or_aiming_started(used_card: CardUI) -> void:
	if used_card == self:
		return
	
	disabled = true


func _on_card_drag_or_aim_ended(_card: CardUI) -> void:
	disabled = false
	_refresh_playable_state()


func _on_char_stats_changed() -> void:
	_refresh_playable_state()


func _refresh_playable_state() -> void:
	if card == null:
		return
	if char_stats == null:
		return
	self.playable = card.can_play(char_stats, battle_context)
