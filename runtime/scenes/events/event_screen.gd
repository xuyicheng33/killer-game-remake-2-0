class_name EventScreen
extends Control

signal event_completed

const EVENT_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/event_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state

@onready var content_margin: MarginContainer = %MarginContainer
@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var result_label: Label = %ResultLabel
@onready var continue_button: Button = %ContinueButton

var _adapter: EventUIAdapter = EVENT_UI_ADAPTER_SCRIPT.new() as EventUIAdapter


func _ready() -> void:
	_connect_signals()
	continue_button.hide()
	# 触发初始渲染
	_adapter.refresh()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	if not _adapter.event_completed.is_connected(_on_event_completed):
		_adapter.event_completed.connect(_on_event_completed)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)


func _disconnect_signals() -> void:
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)
	if _adapter.event_completed.is_connected(_on_event_completed):
		_adapter.event_completed.disconnect(_on_event_completed)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.disconnect(_on_continue_pressed)


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	title_label.text = str(projection.get("title", "未知事件"))
	desc_label.text = str(projection.get("description", "没有描述。"))
	result_label.text = str(projection.get("result_text", ""))

	# Ensure labels have autowrap for long text
	if desc_label.autowrap_mode != TextServer.AUTOWRAP_WORD_SMART:
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if result_label.autowrap_mode != TextServer.AUTOWRAP_WORD_SMART:
		result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var continue_visible := bool(projection.get("continue_visible", false))
	continue_button.visible = continue_visible

	_render_options(projection, continue_visible)


func _render_options(projection: Dictionary, options_disabled: bool) -> void:
	for child in options_container.get_children():
		child.queue_free()

	var options: Variant = projection.get("options", [])
	if not (options is Array):
		return

	for option_variant in options:
		if not (option_variant is Dictionary):
			continue
		var option_data: Dictionary = option_variant

		var btn := Button.new()
		btn.text = str(option_data.get("label", "选项"))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, UILayout.BTN_HEIGHT_DEFAULT)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.disabled = options_disabled

		var option_payload: Variant = option_data.get("option_data", {})
		if option_payload is Dictionary:
			btn.pressed.connect(_on_option_pressed.bind(option_payload as Dictionary))

		options_container.add_child(btn)


func _on_option_pressed(option: Dictionary) -> void:
	_adapter.execute_option(option)


func _on_continue_pressed() -> void:
	_adapter.execute_continue()


func _on_event_completed() -> void:
	event_completed.emit()


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	UILayout.apply_frame_layout(content_margin, viewport_size)
