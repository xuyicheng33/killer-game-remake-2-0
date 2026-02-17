class_name EnemyActionPicker
extends Node

const ENEMY_INTENT_RULES_SCRIPT := preload("res://runtime/modules/enemy_intent/intent_rules.gd")
const REPRO_LOG_SCRIPT := preload("res://runtime/global/repro_log.gd")

@export var enemy: Enemy: set = _set_enemy
@export var target: Node2D: set = _set_target

@export_range(0, 20, 1) var ascension_level := 0
@export var disallow_consecutive := true

var last_action_name: StringName = &""
var _rng_stream_key: String = "enemy_intent:unbound"


func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	_rng_stream_key = _build_rng_stream_key()


func get_action() -> EnemyAction:
	var action: EnemyAction = ENEMY_INTENT_RULES_SCRIPT.pick_next_action(
		_get_actions(),
		last_action_name,
		ascension_level,
		disallow_consecutive,
		_rng_stream_key
	)
	if action != null:
		REPRO_LOG_SCRIPT.log_enemy(_enemy_log_name(), "intent_action=%s stream=%s" % [action.name, _rng_stream_key])
	return action


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
	_rng_stream_key = _build_rng_stream_key()
	
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


func _build_rng_stream_key() -> String:
	if enemy == null:
		return "enemy_intent:unbound"

	var node_id: String = REPRO_LOG_SCRIPT.get_current_node_id()
	if node_id.is_empty():
		node_id = "-"

	var enemy_signature: String = "unknown_enemy"
	if enemy.stats != null and enemy.stats.ai != null:
		var ai_path: String = enemy.stats.ai.resource_path
		if not ai_path.is_empty():
			enemy_signature = ai_path
		else:
			enemy_signature = enemy.stats.ai.resource_name
	elif not enemy.name.is_empty():
		enemy_signature = enemy.name

	return "enemy_intent:%s:%s:%d" % [node_id, enemy_signature, enemy.get_index()]


func _enemy_log_name() -> String:
	if enemy == null:
		return "unknown_enemy"
	return enemy.name
