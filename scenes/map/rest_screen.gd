class_name RestScreen
extends Control

signal rest_completed

@export var run_state: RunState

@onready var hp_label: Label = %HPLabel
@onready var info_label: Label = %InfoLabel
@onready var rest_button: Button = %RestButton
@onready var upgrade_button: Button = %UpgradeButton


func _ready() -> void:
	rest_button.pressed.connect(_on_rest_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	_refresh()


func _refresh() -> void:
	if run_state == null or run_state.player_stats == null:
		hp_label.text = "生命：--/--"
		return
	hp_label.text = "生命：%d/%d" % [run_state.player_stats.health, run_state.player_stats.max_health]


func _on_rest_pressed() -> void:
	if run_state == null or run_state.player_stats == null:
		rest_completed.emit()
		return

	var recover := maxi(6, int(round(run_state.player_stats.max_health * 0.2)))
	run_state.heal_player(recover)
	run_state.next_floor()
	rest_completed.emit()


func _on_upgrade_pressed() -> void:
	if run_state == null:
		rest_completed.emit()
		return

	var upgraded := run_state.upgrade_card_in_deck_at(0)
	if upgraded:
		info_label.text = "升级成功：牌组第 1 张卡已强化。"
	else:
		# Keep "rest/upgrade choose one" meaningful even when upgrade cannot be applied.
		run_state.add_gold(5)
		info_label.text = "无可升级卡，改为获得 5 金币。"

	run_state.next_floor()
	rest_completed.emit()

