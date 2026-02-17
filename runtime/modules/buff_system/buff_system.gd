class_name BuffSystem
extends RefCounted

const STATUS_STRENGTH := "strength"
const STATUS_DEXTERITY := "dexterity"
const STATUS_VULNERABLE := "vulnerable"
const STATUS_WEAK := "weak"
const STATUS_POISON := "poison"

const STATUS_ORDER: Array[String] = [
	STATUS_STRENGTH,
	STATUS_DEXTERITY,
	STATUS_VULNERABLE,
	STATUS_WEAK,
	STATUS_POISON,
]

static var _instance: BuffSystem

var _events_connected := false
var _enemy_turn_queue: Array[Enemy] = []
var _active_enemy: Enemy = null


static func get_instance() -> BuffSystem:
	if _instance == null:
		_instance = BuffSystem.new()
		_instance._connect_events()
	return _instance


func apply_status_to_target(target: Node, status_id: String, stacks: int) -> void:
	var stats: Stats = _extract_stats(target)
	apply_status_to_stats(stats, status_id, stacks)


func apply_status_to_stats(stats: Stats, status_id: String, stacks: int) -> void:
	if stats == null:
		return
	if stacks == 0:
		return
	if not STATUS_ORDER.has(status_id):
		return

	stats.add_status(status_id, stacks)


func get_status_stack(stats: Stats, status_id: String) -> int:
	if stats == null:
		return 0
	return stats.get_status(status_id)


func get_modified_damage(base_damage: int, source: Node, target: Node) -> int:
	var adjusted := maxi(base_damage, 0)
	var source_stats: Stats = _extract_stats(source)
	var target_stats: Stats = _extract_stats(target)

	adjusted += get_status_stack(source_stats, STATUS_STRENGTH)

	if get_status_stack(source_stats, STATUS_WEAK) > 0:
		adjusted = int(floor(float(adjusted) * 0.75))

	if get_status_stack(target_stats, STATUS_VULNERABLE) > 0:
		adjusted = int(ceil(float(adjusted) * 1.5))

	return maxi(adjusted, 0)


func get_modified_block(base_block: int, target: Node) -> int:
	var adjusted := maxi(base_block, 0)
	var target_stats: Stats = _extract_stats(target)
	adjusted += get_status_stack(target_stats, STATUS_DEXTERITY)
	return maxi(adjusted, 0)


func resolve_damage_source(target: Node) -> Node:
	if target == null:
		return null

	if target.is_in_group("enemies"):
		return _get_player_node()

	if target.is_in_group("player"):
		if _active_enemy != null and is_instance_valid(_active_enemy):
			return _active_enemy
		if not _enemy_turn_queue.is_empty():
			var queued_enemy: Enemy = _enemy_turn_queue[0]
			if queued_enemy != null and is_instance_valid(queued_enemy):
				return queued_enemy

		var enemies: Array[Enemy] = _get_enemy_nodes()
		if not enemies.is_empty():
			return enemies[0]

	return null


func on_entity_hit(target: Node, _source: Node, _final_damage: int) -> void:
	if target == null:
		return

	# A4 phase keeps hit hook minimal: status pipeline is now wired for later expansion.
	# Current five statuses do not consume stacks on hit.
	pass


func get_status_badges(stats: Stats) -> Array[Dictionary]:
	var badges: Array[Dictionary] = []

	for status_id in STATUS_ORDER:
		var stacks := get_status_stack(stats, status_id)
		if stacks <= 0:
			continue

		badges.append(
			{
				"id": status_id,
				"label": _get_status_label(status_id),
				"stacks": stacks,
			}
		)

	return badges


func _connect_events() -> void:
	if _events_connected:
		return

	_events_connected = true
	Events.player_hand_drawn.connect(_on_player_turn_start)
	Events.player_turn_ended.connect(_on_player_turn_end)
	Events.player_hand_discarded.connect(_on_enemy_turn_start)
	Events.enemy_turn_ended.connect(_on_enemy_turn_end)
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	Events.card_played.connect(_on_card_played)


func _on_player_turn_start() -> void:
	var player: Player = _get_player_node()
	if player == null:
		return
	_run_turn_start_hooks(player)


func _on_player_turn_end() -> void:
	var player: Player = _get_player_node()
	if player == null:
		return
	_run_turn_end_hooks(player)


func _on_enemy_turn_start() -> void:
	_rebuild_enemy_turn_queue()
	for enemy in _enemy_turn_queue:
		_run_turn_start_hooks(enemy)


func _on_enemy_turn_end() -> void:
	var enemies: Array[Enemy] = _get_enemy_nodes()
	for enemy in enemies:
		_run_turn_end_hooks(enemy)

	_enemy_turn_queue.clear()
	_active_enemy = null


func _on_enemy_action_completed(enemy: Enemy) -> void:
	if _enemy_turn_queue.is_empty():
		_active_enemy = null
		return

	if _enemy_turn_queue[0] == enemy:
		_enemy_turn_queue.pop_front()
	else:
		_enemy_turn_queue.erase(enemy)

	if _enemy_turn_queue.is_empty():
		_active_enemy = null
	else:
		_active_enemy = _enemy_turn_queue[0]


func _on_card_played(_card: Card) -> void:
	var player: Player = _get_player_node()
	if player == null:
		return
	_run_after_card_played_hooks(player)


func _run_turn_start_hooks(_target: Node) -> void:
	# Hook point reserved for statuses with turn-start behavior.
	pass


func _run_turn_end_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return

	_trigger_poison(target, stats)
	_decay_status(stats, STATUS_WEAK)
	_decay_status(stats, STATUS_VULNERABLE)


func _run_after_card_played_hooks(_target: Node) -> void:
	# Hook point reserved for statuses with post-card behavior.
	pass


func _trigger_poison(target: Node, stats: Stats) -> void:
	var poison_stacks := get_status_stack(stats, STATUS_POISON)
	if poison_stacks <= 0:
		return

	stats.health -= poison_stacks
	stats.add_status(STATUS_POISON, -1)

	if target.is_in_group("player"):
		Events.player_hit.emit()

	if stats.health <= 0:
		_handle_death(target)


func _decay_status(stats: Stats, status_id: String) -> void:
	if get_status_stack(stats, status_id) <= 0:
		return

	stats.add_status(status_id, -1)


func _handle_death(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return

	if target.is_in_group("player"):
		Events.player_died.emit()
		target.queue_free()
		return

	if target.is_in_group("enemies"):
		target.queue_free()


func _rebuild_enemy_turn_queue() -> void:
	_enemy_turn_queue.clear()
	var enemies: Array[Enemy] = _get_enemy_nodes()
	for enemy in enemies:
		_enemy_turn_queue.append(enemy)

	if _enemy_turn_queue.is_empty():
		_active_enemy = null
	else:
		_active_enemy = _enemy_turn_queue[0]


func _extract_stats(target: Node) -> Stats:
	if target == null or not is_instance_valid(target):
		return null

	if target is Player:
		var player: Player = target
		return player.stats

	if target is Enemy:
		var enemy: Enemy = target
		return enemy.stats

	return null


func _get_player_node() -> Player:
	var tree := _get_tree()
	if tree == null:
		return null

	var players: Array[Node] = tree.get_nodes_in_group("player")
	if players.is_empty():
		return null

	var first_player: Node = players[0]
	if first_player is Player and is_instance_valid(first_player):
		return first_player as Player

	return null


func _get_enemy_nodes() -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	var tree := _get_tree()
	if tree == null:
		return enemies

	var enemy_nodes: Array[Node] = tree.get_nodes_in_group("enemies")
	for enemy_node in enemy_nodes:
		if enemy_node is Enemy and is_instance_valid(enemy_node):
			enemies.append(enemy_node as Enemy)

	return enemies


func _get_tree() -> SceneTree:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop as SceneTree
	return null


func _get_status_label(status_id: String) -> String:
	match status_id:
		STATUS_STRENGTH:
			return "力"
		STATUS_DEXTERITY:
			return "敏"
		STATUS_VULNERABLE:
			return "易"
		STATUS_WEAK:
			return "弱"
		STATUS_POISON:
			return "毒"
		_:
			return "?"
