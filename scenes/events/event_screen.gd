class_name EventScreen
extends Control

signal event_completed

const EVENT_SERVICE_SCRIPT := preload("res://modules/map_event/event_service.gd")

@export var run_state: RunState

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var result_label: Label = %ResultLabel
@onready var continue_button: Button = %ContinueButton

var _template: Dictionary = {}


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.hide()
	_setup_template()
	_render_options()


func _setup_template() -> void:
	_template = EVENT_SERVICE_SCRIPT.pick_event_template(run_state)
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
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_option_pressed.bind(option_dict))
		options_container.add_child(btn)


func _on_option_pressed(option: Dictionary) -> void:
	var result := EVENT_SERVICE_SCRIPT.apply_option(run_state, option)
	result_label.text = result
	for child in options_container.get_children():
		var btn := child as Button
		if btn:
			btn.disabled = true
	continue_button.show()


func _on_continue_pressed() -> void:
	if run_state:
		run_state.next_floor()
	event_completed.emit()

