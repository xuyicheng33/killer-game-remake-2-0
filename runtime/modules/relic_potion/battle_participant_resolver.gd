class_name BattleParticipantResolver
extends RefCounted


func resolve_player(session_port) -> Player:
	if session_port != null:
		var port_player: Variant = session_port.resolve_player()
		if port_player is Player and is_instance_valid(port_player):
			return port_player as Player
	if not (Engine.get_main_loop() is SceneTree):
		return null
	var players: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("player")
	if players.is_empty():
		return null
	if players[0] is Player:
		return players[0] as Player
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
