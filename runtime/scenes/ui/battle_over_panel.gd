class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	Events.battle_over_screen_requested.connect(show_screen)


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
