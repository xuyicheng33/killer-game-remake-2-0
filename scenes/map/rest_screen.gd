class_name RestScreen
extends Control

signal rest_completed

const REST_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/rest_flow_service.gd")

@export var run_state: RunState

@onready var frame: PanelContainer = %Frame
@onready var hp_label: Label = %HPLabel
@onready var info_label: Label = %InfoLabel
@onready var rest_button: Button = %RestButton
@onready var upgrade_button: Button = %UpgradeButton

var flow_service: RestFlowService


func _ready() -> void:
	if flow_service == null:
		flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService

	_apply_responsive_layout()
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	rest_button.pressed.connect(_on_rest_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	_refresh()


func _refresh() -> void:
	if run_state == null or run_state.player_stats == null:
		hp_label.text = "生命：--/--"
		return
	hp_label.text = "生命：%d/%d" % [run_state.player_stats.health, run_state.player_stats.max_health]


func _on_rest_pressed() -> void:
	var result := flow_service.execute_rest(run_state)
	if bool(result.get("completed", true)):
		rest_completed.emit()


func _on_upgrade_pressed() -> void:
	var result := flow_service.execute_upgrade(run_state)
	info_label.text = str(result.get("info_text", ""))
	if bool(result.get("completed", true)):
		rest_completed.emit()


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	var horizontal_margin := clampf(viewport_size.x * 0.05, 20.0, 160.0)
	var vertical_margin := clampf(viewport_size.y * 0.06, 18.0, 110.0)
	var reserved_overlay_width := clampf(viewport_size.x * 0.23, 280.0, 460.0)

	frame.offset_left = horizontal_margin
	frame.offset_top = vertical_margin
	frame.offset_right = -(horizontal_margin + reserved_overlay_width)
	frame.offset_bottom = -vertical_margin

	var content_width := viewport_size.x + frame.offset_right - frame.offset_left
	if content_width < 700.0:
		frame.offset_right = -horizontal_margin
