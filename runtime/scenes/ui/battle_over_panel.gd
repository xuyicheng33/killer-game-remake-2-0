class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	_connect_signals()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.connect(_on_continue_button_pressed)
	if not restart_button.pressed.is_connected(_on_restart_button_pressed):
		restart_button.pressed.connect(_on_restart_button_pressed)
	if not Events.battle_over_screen_requested.is_connected(show_screen):
		Events.battle_over_screen_requested.connect(show_screen)


func _disconnect_signals() -> void:
	if continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.disconnect(_on_continue_button_pressed)
	if restart_button.pressed.is_connected(_on_restart_button_pressed):
		restart_button.pressed.disconnect(_on_restart_button_pressed)
	if Events.battle_over_screen_requested.is_connected(show_screen):
		Events.battle_over_screen_requested.disconnect(show_screen)


func show_screen(text: String, type: Type) -> void:
	label.text = text
	continue_button.visible = type == Type.WIN
	restart_button.visible = type == Type.LOSE
	show()
	get_tree().paused = true


func _on_continue_button_pressed() -> void:
	_finish_battle(Type.WIN)


func _on_restart_button_pressed() -> void:
	_finish_battle(Type.LOSE)


func _finish_battle(type: Type) -> void:
	hide()
	get_tree().paused = false
	Events.battle_finished.emit(type)
