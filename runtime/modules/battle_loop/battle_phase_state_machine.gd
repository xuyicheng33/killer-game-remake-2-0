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


func bind_context(player: Player, enemies: Array[Enemy], battle_context: RefCounted) -> void:
	_player = player
	_enemies = enemies
	_battle_context = battle_context


func unbind_context() -> void:
	_player = null
	_enemies.clear()
	_battle_context = null


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
	_enter_phase(to_phase)
	phase_changed.emit(from_phase, to_phase, _turn)


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
	if _battle_context != null:
		_battle_context.card_zones.unbind_context()
		_battle_context.card_zones.bind_context(_player.stats, _player.hand)
	
	Events.player_hand_drawn.emit()
	
	if _battle_context != null and _battle_context.buff_system != null:
		_battle_context.buff_system._run_turn_start_hooks(_player)
	
	transition_to(Phase.ACTION)


func _exit_draw_phase() -> void:
	pass


func _enter_action_phase() -> void:
	pass


func _exit_action_phase() -> void:
	Events.player_turn_ended.emit()


func _enter_enemy_phase() -> void:
	Events.player_hand_discarded.emit()
	
	for enemy in _enemies:
		if enemy != null and is_instance_valid(enemy):
			if _battle_context != null and _battle_context.buff_system != null:
				_battle_context.buff_system._run_turn_start_hooks(enemy)
			enemy.take_turn()
	
	Events.enemy_turn_ended.emit()
	
	transition_to(Phase.RESOLVE)


func _exit_enemy_phase() -> void:
	pass


func _enter_resolve_phase() -> void:
	if _battle_context != null and _battle_context.buff_system != null:
		_battle_context.buff_system._run_turn_end_hooks(_player)
		for enemy in _enemies:
			if enemy != null and is_instance_valid(enemy):
				_battle_context.buff_system._run_turn_end_hooks(enemy)
	
	var battle_result := check_battle_end()
	if battle_result.ended:
		battle_ended.emit(battle_result.result)
		return
	
	transition_to(Phase.DRAW)


func _exit_resolve_phase() -> void:
	pass


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


func get_phase_name(phase: Phase = _phase) -> String:
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
