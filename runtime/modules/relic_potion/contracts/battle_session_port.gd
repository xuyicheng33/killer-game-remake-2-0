class_name BattleSessionPort
extends RefCounted

var effect_stack = null
var battle_context = null
var _player_resolver: Callable = Callable()
var _enemy_resolver: Callable = Callable()


func _init(
	battle_effect_stack = null,
	context = null,
	player_resolver: Callable = Callable(),
	enemy_resolver: Callable = Callable()
) -> void:
	effect_stack = battle_effect_stack
	battle_context = context
	_player_resolver = player_resolver
	_enemy_resolver = enemy_resolver


func resolve_player():
	if _player_resolver.is_valid():
		var resolved: Variant = _player_resolver.call()
		if resolved is Node:
			return resolved
	if battle_context != null:
		var player_variant: Variant = battle_context.get_player()
		if player_variant is Node:
			return player_variant
	return null


func resolve_enemies() -> Array[Node]:
	if _enemy_resolver.is_valid():
		var resolved: Variant = _enemy_resolver.call()
		if resolved is Array:
			var out: Array[Node] = []
			for node in resolved:
				if node is Node and is_instance_valid(node):
					out.append(node)
			return out

	if battle_context != null and battle_context.has_method("get_enemies"):
		var enemies: Variant = battle_context.get_enemies()
		if not (enemies is Array):
			enemies = []
		var out: Array[Node] = []
		for enemy in enemies:
			if enemy is Node and is_instance_valid(enemy):
				out.append(enemy)
		return out

	return []
