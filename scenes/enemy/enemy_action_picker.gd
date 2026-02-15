class_name EnemyActionPicker
extends Node

const ENEMY_INTENT_RULES_SCRIPT := preload("res://modules/enemy_intent/intent_rules.gd")

@export var enemy: Enemy: set = _set_enemy
@export var target: Node2D: set = _set_target

@export_range(0, 20, 1) var ascension_level := 0
@export var disallow_consecutive := true

var last_action_name: StringName = &""


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")


func get_action() -> EnemyAction:
	return ENEMY_INTENT_RULES_SCRIPT.pick_next_action(
		_get_actions(),
		last_action_name,
		ascension_level,
		disallow_consecutive
	)


func get_first_conditional_action() -> EnemyAction:
	return ENEMY_INTENT_RULES_SCRIPT.pick_first_conditional_action(
		_get_actions(),
		last_action_name,
		ascension_level,
		disallow_consecutive
	)


func note_action_executed(action: EnemyAction) -> void:
	if not action:
		return
	last_action_name = action.name


func _set_enemy(value: Enemy) -> void:
	enemy = value
	
	for action: EnemyAction in get_children():
		action.enemy = enemy


func _set_target(value: Node2D) -> void:
	target = value
	
	for action: EnemyAction in get_children():
		action.target = target


func _get_actions() -> Array[EnemyAction]:
	var out: Array[EnemyAction] = []
	for child in get_children():
		var action := child as EnemyAction
		if action:
			out.append(action)
	return out
