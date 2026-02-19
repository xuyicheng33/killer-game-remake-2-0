class_name BuffSystem
extends RefCounted

const STATUS_STRENGTH := "strength"
const STATUS_DEXTERITY := "dexterity"
const STATUS_VULNERABLE := "vulnerable"
const STATUS_WEAK := "weak"
const STATUS_POISON := "poison"
const STATUS_BURN := "burn"
const STATUS_CONSTRICTED := "constricted"
const STATUS_METALLICIZE := "metallicize"
const STATUS_RITUAL := "ritual"
const STATUS_REGENERATE := "regenerate"

const STATUS_ORDER: Array[String] = [
	STATUS_STRENGTH,
	STATUS_DEXTERITY,
	STATUS_VULNERABLE,
	STATUS_WEAK,
	STATUS_POISON,
	STATUS_BURN,
	STATUS_CONSTRICTED,
	STATUS_METALLICIZE,
	STATUS_RITUAL,
	STATUS_REGENERATE,
]

var _events_connected := false
var _enemy_turn_queue: Array[Enemy] = []
var _active_enemy: Enemy = null


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


func connect_events() -> void:
	if _events_connected:
		return

	_events_connected = true
	Events.player_hand_drawn.connect(_on_player_turn_start)
	Events.player_hand_discarded.connect(_on_player_turn_end)
	Events.enemy_turn_started.connect(_on_enemy_turn_start)
	Events.enemy_turn_ended.connect(_on_enemy_turn_end)
	Events.enemy_action_completed.connect(_on_enemy_action_completed)
	Events.card_played.connect(_on_card_played)


func disconnect_events() -> void:
	if not _events_connected:
		return

	_events_connected = false
	if Events.player_hand_drawn.is_connected(_on_player_turn_start):
		Events.player_hand_drawn.disconnect(_on_player_turn_start)
	if Events.player_hand_discarded.is_connected(_on_player_turn_end):
		Events.player_hand_discarded.disconnect(_on_player_turn_end)
	if Events.enemy_turn_started.is_connected(_on_enemy_turn_start):
		Events.enemy_turn_started.disconnect(_on_enemy_turn_start)
	if Events.enemy_turn_ended.is_connected(_on_enemy_turn_end):
		Events.enemy_turn_ended.disconnect(_on_enemy_turn_end)
	if Events.enemy_action_completed.is_connected(_on_enemy_action_completed):
		Events.enemy_action_completed.disconnect(_on_enemy_action_completed)
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)


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


func _run_turn_start_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return
	
	_trigger_poison(target, stats)


func _run_turn_end_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return

	_trigger_burn(target, stats)
	_trigger_constricted(target, stats)
	_trigger_metallicize(target, stats)
	_trigger_ritual(target, stats)
	_trigger_regenerate(target, stats)
	_decay_status(stats, STATUS_WEAK)
	_decay_status(stats, STATUS_VULNERABLE)


func _run_after_card_played_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return
	
	var status_dict: Dictionary = stats.get_status_snapshot()
	for status_id: String in status_dict.keys():
		var stacks_variant: Variant = status_dict[status_id]
		if not (stacks_variant is int):
			continue
		var stacks: int = stacks_variant
		if stacks <= 0:
			continue
		
		match status_id:
			STATUS_STRENGTH, STATUS_DEXTERITY, STATUS_VULNERABLE, STATUS_WEAK, STATUS_POISON:
				pass
			STATUS_BURN, STATUS_CONSTRICTED, STATUS_METALLICIZE, STATUS_RITUAL, STATUS_REGENERATE:
				pass
			_:
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


func _trigger_burn(target: Node, stats: Stats) -> void:
	var burn_stacks := get_status_stack(stats, STATUS_BURN)
	if burn_stacks <= 0:
		return

	stats.health -= 2
	stats.set_status(STATUS_BURN, 0)

	if target.is_in_group("player"):
		Events.player_hit.emit()

	if stats.health <= 0:
		_handle_death(target)


func _trigger_constricted(target: Node, stats: Stats) -> void:
	var constricted_stacks := get_status_stack(stats, STATUS_CONSTRICTED)
	if constricted_stacks <= 0:
		return

	stats.health -= constricted_stacks

	if target.is_in_group("player"):
		Events.player_hit.emit()

	if stats.health <= 0:
		_handle_death(target)


func _trigger_metallicize(_target: Node, stats: Stats) -> void:
	var metallicize_stacks := get_status_stack(stats, STATUS_METALLICIZE)
	if metallicize_stacks <= 0:
		return

	stats.block += metallicize_stacks
	if _target != null and _target.is_in_group("player"):
		Events.player_block_applied.emit(metallicize_stacks, "status:metallicize")


func _trigger_ritual(_target: Node, stats: Stats) -> void:
	var ritual_stacks := get_status_stack(stats, STATUS_RITUAL)
	if ritual_stacks <= 0:
		return

	stats.add_status(STATUS_STRENGTH, ritual_stacks)


func _trigger_regenerate(target: Node, stats: Stats) -> void:
	var regen_stacks := get_status_stack(stats, STATUS_REGENERATE)
	if regen_stacks <= 0:
		return

	var heal_amount := mini(regen_stacks, stats.max_health - stats.health)
	if heal_amount > 0:
		stats.health += heal_amount
	
	_decay_status(stats, STATUS_REGENERATE)


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
		var enemy := target as Enemy
		Events.enemy_died.emit(enemy)
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
		STATUS_BURN:
			return "燃"
		STATUS_CONSTRICTED:
			return "缚"
		STATUS_METALLICIZE:
			return "金"
		STATUS_RITUAL:
			return "怒"
		STATUS_REGENERATE:
			return "再"
		_:
			return "?"
