class_name EventScreen
extends Control

signal event_completed

const EVENT_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/event_flow_service.gd")

@export var run_state: RunState

@onready var content_margin: MarginContainer = %MarginContainer
@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var result_label: Label = %ResultLabel
@onready var continue_button: Button = %ContinueButton

var _template: Dictionary = {}
var flow_service: EventFlowService


func _ready() -> void:
	if flow_service == null:
		flow_service = EVENT_FLOW_SERVICE_SCRIPT.new() as EventFlowService

	_apply_responsive_layout()
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.hide()
	_setup_template()
	_render_options()


func _setup_template() -> void:
	_template = flow_service.pick_event_template(run_state)
	title_label.text = str(_template.get("title", "未知事件"))
	desc_label.text = str(_template.get("description", "没有描述。"))


func _render_options() -> void:
	for child in options_container.get_children():
		child.queue_free()

	var options := _template.get("options", []) as Array
	for option in options:
		var option_dict := option as Dictionary
		var btn := Button.new()
		btn.text = str(option_dict.get("label", "选项"))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 64)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_option_pressed.bind(option_dict))
		options_container.add_child(btn)


func _on_option_pressed(option: Dictionary) -> void:
	var result := flow_service.execute_option(run_state, option)
	result_label.text = result
	for child in options_container.get_children():
		var btn := child as Button
		if btn:
			btn.disabled = true
	continue_button.show()


func _on_continue_pressed() -> void:
	flow_service.execute_continue(run_state)
	event_completed.emit()


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	var horizontal_margin := clampf(viewport_size.x * 0.05, 20.0, 180.0)
	var vertical_margin := clampf(viewport_size.y * 0.06, 18.0, 120.0)
	var reserved_overlay_width := clampf(viewport_size.x * 0.23, 280.0, 460.0)

	content_margin.offset_left = horizontal_margin
	content_margin.offset_top = vertical_margin
	content_margin.offset_right = -(horizontal_margin + reserved_overlay_width)
	content_margin.offset_bottom = -vertical_margin

	var content_width := viewport_size.x + content_margin.offset_right - content_margin.offset_left
	if content_width < 700.0:
		content_margin.offset_right = -horizontal_margin
