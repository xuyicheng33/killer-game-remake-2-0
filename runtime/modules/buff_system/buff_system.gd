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

var _status_registry: Dictionary = {}
var _status_order: Array[String] = []

var _events_connected := false
var _enemy_turn_queue: Array[Node] = []
var _active_enemy: Node = null
var _player: Node = null
var _enemies: Array[Node] = []
var _role_map: Dictionary = {}
var _player_damage_multiplier := 1.0


func _init() -> void:
	_register_builtin_statuses()


func register_status(handler: StatusHandler) -> void:
	_status_registry[handler.id] = handler
	if not _status_order.has(handler.id):
		_status_order.append(handler.id)


func has_status(status_id: String) -> bool:
	return _status_registry.has(status_id)


func bind_combatants(player: Node, enemies: Array[Node]) -> void:
	_player = player
	_enemies = enemies.duplicate()
	_role_map.clear()
	if player != null:
		_role_map[player] = CombatantRole.Type.PLAYER
	for enemy in enemies:
		_role_map[enemy] = CombatantRole.Type.ENEMY


func unbind_combatants() -> void:
	_player = null
	_enemies.clear()
	_role_map.clear()


func remove_enemy(enemy: Node) -> void:
	_enemies.erase(enemy)
	_role_map.erase(enemy)
	if _active_enemy == enemy:
		_active_enemy = null
	_enemy_turn_queue.erase(enemy)


func apply_status_to_target(target: Node, status_id: String, stacks: int) -> void:
	var stats: Stats = _extract_stats(target)
	apply_status_to_stats(stats, status_id, stacks)


func apply_status_to_stats(stats: Stats, status_id: String, stacks: int) -> void:
	if stats == null:
		return
	if stacks == 0:
		return
	if not _status_registry.has(status_id):
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

	if _get_role(source) == CombatantRole.Type.PLAYER:
		adjusted = int(round(float(adjusted) * _player_damage_multiplier))

	if get_status_stack(source_stats, STATUS_WEAK) > 0:
		adjusted = int(floor(float(adjusted) * 0.75))

	if get_status_stack(target_stats, STATUS_VULNERABLE) > 0:
		adjusted = int(ceil(float(adjusted) * 1.5))

	return maxi(adjusted, 0)


func set_player_damage_multiplier(multiplier: float) -> void:
	_player_damage_multiplier = multiplier


func reset_player_damage_multiplier() -> void:
	_player_damage_multiplier = 1.0


func get_modified_block(base_block: int, target: Node) -> int:
	var adjusted := maxi(base_block, 0)
	var target_stats: Stats = _extract_stats(target)
	adjusted += get_status_stack(target_stats, STATUS_DEXTERITY)
	return maxi(adjusted, 0)


func resolve_damage_source(target: Node) -> Node:
	if target == null:
		return null

	if _get_role(target) == CombatantRole.Type.ENEMY:
		return _get_player_node()

	if _get_role(target) == CombatantRole.Type.PLAYER:
		if _active_enemy != null and is_instance_valid(_active_enemy):
			return _active_enemy
		if not _enemy_turn_queue.is_empty():
			var queued_enemy: Node = _enemy_turn_queue[0]
			if queued_enemy != null and is_instance_valid(queued_enemy):
				return queued_enemy

		var enemies: Array[Node] = _get_enemy_nodes()
		if not enemies.is_empty():
			return enemies[0]

	return null


func on_entity_hit(target: Node, source: Node, final_damage: int) -> void:
	if target == null:
		return
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return
	for status_id in _status_order:
		var stacks := get_status_stack(stats, status_id)
		if stacks <= 0:
			continue
		var handler: StatusHandler = _status_registry.get(status_id)
		if handler != null and handler.on_entity_hit.is_valid():
			handler.on_entity_hit.call(target, stats, stacks, source, final_damage)


func get_status_badges(stats: Stats) -> Array[Dictionary]:
	var badges: Array[Dictionary] = []

	for status_id in _status_order:
		var stacks := get_status_stack(stats, status_id)
		if stacks <= 0:
			continue

		var handler: StatusHandler = _status_registry.get(status_id)
		var label := handler.label if handler != null else "?"
		badges.append({"id": status_id, "label": label, "stacks": stacks})

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
	reset_player_damage_multiplier()
	var player: Node = _get_player_node()
	if player == null:
		return
	_run_turn_start_hooks(player)


func _on_player_turn_end() -> void:
	var player: Node = _get_player_node()
	if player == null:
		return
	_run_turn_end_hooks(player)


func _on_enemy_turn_start() -> void:
	_rebuild_enemy_turn_queue()
	for enemy in _enemy_turn_queue:
		_run_turn_start_hooks(enemy)


func _on_enemy_turn_end() -> void:
	var enemies: Array[Node] = _get_enemy_nodes()
	for enemy in enemies:
		_run_turn_end_hooks(enemy)

	_enemy_turn_queue.clear()
	_active_enemy = null


func _on_enemy_action_completed(enemy: Node) -> void:
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
	var player: Node = _get_player_node()
	if player == null:
		return
	_run_after_card_played_hooks(player)


func _run_turn_start_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return
	for status_id in _status_order:
		var stacks := get_status_stack(stats, status_id)
		if stacks <= 0:
			continue
		var handler: StatusHandler = _status_registry.get(status_id)
		if handler != null and handler.on_turn_start.is_valid():
			handler.on_turn_start.call(target, stats, stacks)
		if stats.health <= 0:
			_handle_death(target)
			return


func _run_turn_end_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return
	for status_id in _status_order:
		var stacks := get_status_stack(stats, status_id)
		if stacks <= 0:
			continue
		var handler: StatusHandler = _status_registry.get(status_id)
		if handler != null and handler.on_turn_end.is_valid():
			handler.on_turn_end.call(target, stats, stacks)
		if handler != null and handler.decays_on_turn_end:
			_decay_status(stats, status_id)
		if stats.health <= 0:
			_handle_death(target)
			return


func _run_after_card_played_hooks(target: Node) -> void:
	var stats: Stats = _extract_stats(target)
	if stats == null:
		return
	for status_id in _status_order:
		var stacks := get_status_stack(stats, status_id)
		if stacks <= 0:
			continue
		var handler: StatusHandler = _status_registry.get(status_id)
		if handler != null and handler.on_card_played.is_valid():
			handler.on_card_played.call(target, stats, stacks)


func _decay_status(stats: Stats, status_id: String) -> void:
	if get_status_stack(stats, status_id) <= 0:
		return

	stats.add_status(status_id, -1)


func _handle_death(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return

	if _get_role(target) == CombatantRole.Type.PLAYER:
		Events.player_died.emit()
		return

	if _get_role(target) == CombatantRole.Type.ENEMY:
		Events.enemy_died.emit(target)
		return


func _rebuild_enemy_turn_queue() -> void:
	_enemy_turn_queue.clear()
	var enemies: Array[Node] = _get_enemy_nodes()
	for enemy in enemies:
		_enemy_turn_queue.append(enemy)

	if _enemy_turn_queue.is_empty():
		_active_enemy = null
	else:
		_active_enemy = _enemy_turn_queue[0]


func _extract_stats(target: Node) -> Stats:
	if target == null or not is_instance_valid(target):
		return null
	var s = target.get("stats")
	if s is Stats:
		return s
	return null


func _get_role(target: Node) -> int:
	if target == null or not is_instance_valid(target):
		return CombatantRole.Type.UNKNOWN
	return _role_map.get(target, CombatantRole.Type.UNKNOWN)


func _get_player_node() -> Node:
	if _player != null and is_instance_valid(_player):
		return _player
	return null


func _get_enemy_nodes() -> Array[Node]:
	var valid_enemies: Array[Node] = []
	for enemy in _enemies:
		if enemy != null and is_instance_valid(enemy):
			valid_enemies.append(enemy)
	return valid_enemies


func _register_builtin_statuses() -> void:
	register_status(StatusHandler.create(STATUS_STRENGTH, "力"))
	register_status(StatusHandler.create(STATUS_DEXTERITY, "敏"))
	register_status(StatusHandler.create(STATUS_VULNERABLE, "易", Callable(), Callable(), true))
	register_status(StatusHandler.create(STATUS_WEAK, "弱", Callable(), Callable(), true))
	register_status(StatusHandler.create(STATUS_POISON, "毒",
		func(target: Node, stats: Stats, stacks: int) -> void:
			stats.health -= stacks
			stats.add_status(STATUS_POISON, -1)
			if _get_role(target) == CombatantRole.Type.PLAYER:
				Events.player_hit.emit()
	))
	register_status(StatusHandler.create(STATUS_BURN, "燃", Callable(),
		func(target: Node, stats: Stats, stacks: int) -> void:
			stats.health -= stacks
			if _get_role(target) == CombatantRole.Type.PLAYER:
				Events.player_hit.emit(),
		true
	))
	register_status(StatusHandler.create(STATUS_CONSTRICTED, "缚", Callable(),
		func(target: Node, stats: Stats, stacks: int) -> void:
			stats.health -= stacks
			if _get_role(target) == CombatantRole.Type.PLAYER:
				Events.player_hit.emit()
	))
	register_status(StatusHandler.create(STATUS_METALLICIZE, "金", Callable(),
		func(target: Node, stats: Stats, stacks: int) -> void:
			stats.block += stacks
			if _get_role(target) == CombatantRole.Type.PLAYER:
				Events.player_block_applied.emit(stacks, "status:metallicize")
	))
	register_status(StatusHandler.create(STATUS_RITUAL, "怒", Callable(),
		func(_target: Node, stats: Stats, stacks: int) -> void:
			stats.add_status(STATUS_STRENGTH, stacks)
	))
	register_status(StatusHandler.create(STATUS_REGENERATE, "再", Callable(),
		func(_target: Node, stats: Stats, stacks: int) -> void:
			var heal_amount := mini(stacks, stats.max_health - stats.health)
			if heal_amount > 0:
				stats.health += heal_amount,
		true
	))
