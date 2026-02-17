class_name RestScreen
extends Control

signal rest_completed

const REST_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/rest_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state

@onready var frame: PanelContainer = %Frame
@onready var hp_label: Label = %HPLabel
@onready var info_label: Label = %InfoLabel
@onready var rest_button: Button = %RestButton
@onready var upgrade_button: Button = %UpgradeButton

var _adapter: RestUIAdapter = REST_UI_ADAPTER_SCRIPT.new() as RestUIAdapter


func _ready() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	if not _adapter.rest_completed.is_connected(_on_rest_completed):
		_adapter.rest_completed.connect(_on_rest_completed)

	_apply_responsive_layout()
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	rest_button.pressed.connect(_on_rest_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	_adapter.refresh()


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	hp_label.text = str(projection.get("hp_text", "生命：--/--"))
	rest_button.disabled = bool(projection.get("rest_button_disabled", true))
	upgrade_button.disabled = bool(projection.get("upgrade_button_disabled", true))


func _on_rest_pressed() -> void:
	_adapter.execute_rest()


func _on_upgrade_pressed() -> void:
	var result := _adapter.execute_upgrade()
	info_label.text = str(result.get("info_text", ""))


func _on_rest_completed() -> void:
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
