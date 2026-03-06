class_name EnemyActionPicker
extends Node

const ENEMY_INTENT_RULES_SCRIPT := preload("res://runtime/modules/enemy_intent/intent_rules.gd")
const INTENT_ACTION_DATA_SCRIPT := preload("res://runtime/modules/enemy_intent/intent_action_data.gd")
const REPRO_LOG_SCRIPT := preload("res://runtime/global/repro_log.gd")

@export var enemy: Enemy: set = _set_enemy
@export var target: Node2D: set = _set_target
var battle_context: RefCounted: set = _set_battle_context

@export_range(0, 20, 1) var ascension_level := 0
@export var disallow_consecutive := true

var last_action_name: StringName = &""
var _rng_stream_key: String = "enemy_intent:unbound"


func _ready() -> void:
	target = _resolve_target_from_context()
	_rng_stream_key = _build_rng_stream_key()


func get_action() -> EnemyAction:
	var actions := _get_actions()
	var data_list := _to_intent_data(actions)
	var picked: Variant = ENEMY_INTENT_RULES_SCRIPT.pick_next_action(
		data_list,
		last_action_name,
		ascension_level,
		disallow_consecutive,
		_rng_stream_key
	)
	var action := _resolve_action(picked, actions)
	if action != null:
		REPRO_LOG_SCRIPT.log_enemy(_enemy_log_name(), "intent_action=%s stream=%s" % [action.name, _rng_stream_key])
	return action


func get_first_conditional_action() -> EnemyAction:
	var actions := _get_actions()
	var data_list := _to_intent_data(actions)
	var picked: Variant = ENEMY_INTENT_RULES_SCRIPT.pick_first_conditional_action(
		data_list,
		last_action_name,
		ascension_level,
		disallow_consecutive
	)
	return _resolve_action(picked, actions)


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


func _set_battle_context(value: RefCounted) -> void:
	battle_context = value
	target = _resolve_target_from_context()

	for action: EnemyAction in get_children():
		action.battle_context = battle_context
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

	return "enemy_intent:%s:%s:%s" % [node_id, enemy_signature, _enemy_slot_signature()]


func _enemy_log_name() -> String:
	if enemy == null:
		return "unknown_enemy"
	return enemy.name


func _to_intent_data(actions: Array[EnemyAction]) -> Array:
	var out: Array = []
	for i in range(actions.size()):
		var a := actions[i]
		var t := INTENT_ACTION_DATA_SCRIPT.ActionType.CONDITIONAL if a.type == EnemyAction.Type.CONDITIONAL else INTENT_ACTION_DATA_SCRIPT.ActionType.CHANCE_BASED
		out.append(INTENT_ACTION_DATA_SCRIPT.from_values(
			t, a.name, a.is_performable(), a.get_effective_weight(ascension_level), i
		))
	return out


func _resolve_action(data: Variant, actions: Array[EnemyAction]) -> EnemyAction:
	if data == null:
		return null
	if data.source_index >= 0 and data.source_index < actions.size():
		return actions[data.source_index]
	return null


func _resolve_target_from_context() -> Node2D:
	if battle_context != null and battle_context.has_method("get_player"):
		var player_variant: Variant = battle_context.get_player()
		if player_variant is Node2D:
			return player_variant
	return null


func _enemy_slot_signature() -> String:
	if enemy == null:
		return "unbound"
	var parent := enemy.get_parent()
	if parent == null:
		return enemy.name if not enemy.name.is_empty() else "detached"
	var enemy_index := 0
	for child in parent.get_children():
		if child is Enemy:
			if child == enemy:
				return str(enemy_index)
			enemy_index += 1
	return enemy.name if not enemy.name.is_empty() else "unknown"
