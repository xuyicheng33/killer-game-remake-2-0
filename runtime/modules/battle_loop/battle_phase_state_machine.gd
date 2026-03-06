class_name BattlePhaseStateMachine
extends RefCounted

enum Phase {
	INVALID = -1,
	DRAW,
	ACTION,
	ENEMY,
	RESOLVE,
}

signal phase_changed(from_phase: Phase, to_phase: Phase, turn: int)
signal battle_ended(result: String)

var _phase: Phase = Phase.INVALID
var _turn := 0
var _player: Player = null
var _enemies: Array[Enemy] = []
var _battle_context: RefCounted = null
var _player_handler: PlayerHandler = null
var _enemy_handler: EnemyHandler = null
var _battle_setup_done := false
var _resolve_waiting_for_discard := false


func bind_context(player: Player, enemies: Array[Enemy], battle_context: RefCounted) -> void:
	_player = player
	_enemies = enemies
	_battle_context = battle_context
	_battle_setup_done = false


func bind_turn_handlers(player_handler: PlayerHandler, enemy_handler: EnemyHandler) -> void:
	_player_handler = player_handler
	_enemy_handler = enemy_handler


func unbind_context() -> void:
	_player = null
	_enemies.clear()
	_battle_context = null
	_player_handler = null
	_enemy_handler = null
	_battle_setup_done = false
	_resolve_waiting_for_discard = false


func get_phase() -> Phase:
	return _phase


func get_turn() -> int:
	return _turn


func get_player() -> Player:
	return _player


func get_enemies() -> Array[Enemy]:
	return _enemies


func start() -> void:
	_turn = 1
	_battle_setup_done = false
	_transition_to(Phase.DRAW)


func can_transition(to_phase: Phase) -> bool:
	match _phase:
		Phase.INVALID:
			return to_phase == Phase.DRAW
		Phase.DRAW:
			return to_phase == Phase.ACTION
		Phase.ACTION:
			return to_phase == Phase.ENEMY
		Phase.ENEMY:
			return to_phase == Phase.RESOLVE
		Phase.RESOLVE:
			return to_phase == Phase.DRAW
		_:
			return false


func transition_to(to_phase: Phase) -> bool:
	if not can_transition(to_phase):
		return false

	_exit_phase(_phase)
	
	if _phase == Phase.RESOLVE and to_phase == Phase.DRAW:
		_turn += 1

	_transition_to(to_phase)
	return true


func _transition_to(to_phase: Phase) -> void:
	var from_phase := _phase
	_phase = to_phase
	phase_changed.emit(from_phase, to_phase, _turn)
	_enter_phase(to_phase)


func _enter_phase(phase: Phase) -> void:
	match phase:
		Phase.DRAW:
			_enter_draw_phase()
		Phase.ACTION:
			_enter_action_phase()
		Phase.ENEMY:
			_enter_enemy_phase()
		Phase.RESOLVE:
			_enter_resolve_phase()


func _exit_phase(phase: Phase) -> void:
	match phase:
		Phase.DRAW:
			_exit_draw_phase()
		Phase.ACTION:
			_exit_action_phase()
		Phase.ENEMY:
			_exit_enemy_phase()
		Phase.RESOLVE:
			_exit_resolve_phase()


func _enter_draw_phase() -> void:
	if _player_handler == null or not is_instance_valid(_player_handler):
		return
	if _player == null or not is_instance_valid(_player):
		return
	if _player.stats == null:
		return

	if not _battle_setup_done:
		_player_handler.start_battle(_player.stats)
		_battle_setup_done = true
		return

	_player_handler.start_turn()


func _exit_draw_phase() -> void:
	pass


func _enter_action_phase() -> void:
	pass


func _exit_action_phase() -> void:
	pass


func _enter_enemy_phase() -> void:
	if _enemy_handler == null or not is_instance_valid(_enemy_handler):
		return
	if _count_alive_enemies() == 0:
		transition_to(Phase.RESOLVE)
		return
	Events.enemy_turn_started.emit()
	_enemy_handler.start_turn()


func _exit_enemy_phase() -> void:
	pass


func _enter_resolve_phase() -> void:
	_resolve_waiting_for_discard = true
	if _player_handler == null or not is_instance_valid(_player_handler):
		on_resolve_discard_completed()
		return
	_player_handler.end_turn()


func _exit_resolve_phase() -> void:
	_resolve_waiting_for_discard = false


func on_resolve_discard_completed() -> void:
	if _phase != Phase.RESOLVE:
		return
	if not _resolve_waiting_for_discard:
		return
	_resolve_waiting_for_discard = false

	if _enemy_handler != null and is_instance_valid(_enemy_handler):
		_enemy_handler.reset_enemy_actions()

	var battle_result := check_battle_end()
	if battle_result.ended:
		battle_ended.emit(battle_result.result)
		return

	transition_to(Phase.DRAW)


func check_battle_end() -> Dictionary:
	if _player == null or not is_instance_valid(_player):
		return {"ended": true, "result": "defeat"}
	
	if _player.stats != null and _player.stats.health <= 0:
		return {"ended": true, "result": "defeat"}
	
	var alive_enemies := 0
	for enemy in _enemies:
		if enemy != null and is_instance_valid(enemy) and enemy.stats != null:
			if enemy.stats.health > 0:
				alive_enemies += 1
	
	if alive_enemies == 0:
		return {"ended": true, "result": "victory"}
	
	return {"ended": false}


func get_phase_name(phase: Phase = Phase.INVALID) -> String:
	if phase == Phase.INVALID:
		phase = _phase
	match phase:
		Phase.DRAW:
			return "DRAW"
		Phase.ACTION:
			return "ACTION"
		Phase.ENEMY:
			return "ENEMY"
		Phase.RESOLVE:
			return "RESOLVE"
		_:
			return "INVALID"


func remove_enemy(enemy: Enemy) -> void:
	_enemies.erase(enemy)


func _count_alive_enemies() -> int:
	var alive := 0
	for enemy in _enemies:
		if enemy != null and is_instance_valid(enemy) and enemy.stats != null and enemy.stats.health > 0:
			alive += 1
	return alive
