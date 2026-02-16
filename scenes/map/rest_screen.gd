class_name RestScreen
extends Control

signal rest_completed

const REST_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/rest_flow_service.gd")

@export var run_state: RunState

@onready var hp_label: Label = %HPLabel
@onready var info_label: Label = %InfoLabel
@onready var rest_button: Button = %RestButton
@onready var upgrade_button: Button = %UpgradeButton

var flow_service: RestFlowService


func _ready() -> void:
	if flow_service == null:
		flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService

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
