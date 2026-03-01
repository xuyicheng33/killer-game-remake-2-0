class_name BattleParticipantResolver
extends RefCounted


func resolve_player(session_port) -> Node:
	if session_port != null:
		var port_player: Variant = session_port.resolve_player()
		var resolved_port_player: Node = _as_live_node(port_player)
		if _is_player_node(resolved_port_player):
			return resolved_port_player
	if not (Engine.get_main_loop() is SceneTree):
		return null
	var players: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("player")
	if players.is_empty():
		return null
	var first_player: Node = players[0]
	if _is_player_node(first_player):
		return first_player
	return null


func resolve_battle_context(session_port, cached_context: BattleContext) -> BattleContext:
	if session_port != null:
		return session_port.battle_context
	if cached_context != null:
		return cached_context
	return null


func resolve_enemies(session_port) -> Array[Node]:
	if session_port != null:
		var port_enemies: Variant = session_port.resolve_enemies()
		if not (port_enemies is Array):
			port_enemies = []
		if not port_enemies.is_empty():
			var typed_enemies: Array[Node] = []
			for enemy in port_enemies:
				if enemy is Node and is_instance_valid(enemy):
					typed_enemies.append(enemy)
			return typed_enemies

	var result: Array[Node] = []
	if not (Engine.get_main_loop() is SceneTree):
		return result
	var nodes: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("enemies")
	for node in nodes:
		if node != null and is_instance_valid(node):
			result.append(node)
	return result


func _as_live_node(value: Variant) -> Node:
	if value is Node and is_instance_valid(value):
		return value as Node
	return null


func _is_player_node(node: Node) -> bool:
	if node == null or not is_instance_valid(node):
		return false
	return node.is_in_group("player")
