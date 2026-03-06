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
	_connect_signals()
	_adapter.refresh()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	if not _adapter.rest_completed.is_connected(_on_rest_completed):
		_adapter.rest_completed.connect(_on_rest_completed)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	if not rest_button.pressed.is_connected(_on_rest_pressed):
		rest_button.pressed.connect(_on_rest_pressed)
	if not upgrade_button.pressed.is_connected(_on_upgrade_pressed):
		upgrade_button.pressed.connect(_on_upgrade_pressed)


func _disconnect_signals() -> void:
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)
	if _adapter.rest_completed.is_connected(_on_rest_completed):
		_adapter.rest_completed.disconnect(_on_rest_completed)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if rest_button.pressed.is_connected(_on_rest_pressed):
		rest_button.pressed.disconnect(_on_rest_pressed)
	if upgrade_button.pressed.is_connected(_on_upgrade_pressed):
		upgrade_button.pressed.disconnect(_on_upgrade_pressed)


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	hp_label.text = str(projection.get("hp_text", "生命：--/--"))
	rest_button.disabled = bool(projection.get("rest_button_disabled", true))
	upgrade_button.disabled = bool(projection.get("upgrade_button_disabled", true))

	# Ensure info_label has autowrap for long text
	if info_label.autowrap_mode != TextServer.AUTOWRAP_WORD_SMART:
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


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
	UILayout.apply_frame_layout(frame, viewport_size)
