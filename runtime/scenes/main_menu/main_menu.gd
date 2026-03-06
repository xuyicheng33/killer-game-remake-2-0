class_name MainMenu
extends Control

signal new_game_requested(character_id: String)
signal continue_game_requested

const SAVE_SERVICE_SCRIPT := preload("res://runtime/modules/persistence/save_service.gd")
const CHARACTER_REGISTRY_SCRIPT := preload("res://runtime/modules/run_meta/character_registry.gd")

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var character_selection_container: HBoxContainer = %CharacterSelectionContainer
@onready var selected_character_label: Label = %SelectedCharacterLabel
@onready var save_status_label: Label = %SaveStatusLabel

var selected_character_id: String = ""
var available_characters: Array[String] = []


func _ready() -> void:
	_connect_signals()
	_initialize_character_selection()
	_update_ui_state()


func _connect_signals() -> void:
	if not new_game_button.pressed.is_connected(_on_new_game_pressed):
		new_game_button.pressed.connect(_on_new_game_pressed)
	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)


func _initialize_character_selection() -> void:
	# 从 CharacterRegistry 动态获取可用角色列表
	available_characters = CHARACTER_REGISTRY_SCRIPT.get_available_character_ids()
	# 使用默认角色作为初始选择
	selected_character_id = CHARACTER_REGISTRY_SCRIPT.get_selected_character_id()
	_update_character_display()
	_create_character_buttons()


func _create_character_buttons() -> void:
	# 清除现有按钮
	for child in character_selection_container.get_children():
		child.queue_free()

	# 为每个可用角色创建按钮
	for character_id in available_characters:
		var button := Button.new()
		button.text = _get_character_display_name(character_id)
		button.toggle_mode = true
		button.button_pressed = (character_id == selected_character_id)
		button.custom_minimum_size = Vector2(120, 48)

		var callable := func(pressed: bool, cid: String = character_id) -> void:
			if not pressed:
				return
			_on_character_button_pressed(cid)
		button.toggled.connect(callable)

		character_selection_container.add_child(button)


func _get_character_display_name(character_id: String) -> String:
	match character_id:
		"warrior":
			return "战士"
		"mage":
			return "法师"
		_:
			return character_id


func _update_character_display() -> void:
	var display_name := _get_character_display_name(selected_character_id)
	selected_character_label.text = "当前选择：%s" % display_name


func _update_ui_state() -> void:
	var has_save: bool = SAVE_SERVICE_SCRIPT.has_save()
	continue_button.disabled = not has_save

	if has_save:
		continue_button.text = "继续游戏"
		save_status_label.text = "检测到存档"
		save_status_label.modulate = UIColors.SAVE_EXISTS
	else:
		continue_button.text = "继续游戏（无存档）"
		save_status_label.text = "无存档"
		save_status_label.modulate = UIColors.SAVE_MISSING


func _on_character_button_pressed(character_id: String) -> void:
	selected_character_id = character_id
	_update_character_display()
	_update_character_buttons()


func _update_character_buttons() -> void:
	var buttons := character_selection_container.get_children()
	for i in range(buttons.size()):
		var button: Button = buttons[i]
		if i < available_characters.size():
			button.set_pressed_no_signal(available_characters[i] == selected_character_id)


func _on_new_game_pressed() -> void:
	new_game_requested.emit(selected_character_id)


func _on_continue_pressed() -> void:
	continue_game_requested.emit()
