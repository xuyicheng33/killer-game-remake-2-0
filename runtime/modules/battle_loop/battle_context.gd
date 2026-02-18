class_name BattleContext
extends RefCounted

var effect_stack: EffectStackEngine
var buff_system: BuffSystem
var card_zones: CardZonesModel
var phase_machine: BattlePhaseStateMachine
var _character: CharacterStats
var _hand: Hand
var _player: Player
var _enemies: Array[Enemy] = []


func _init() -> void:
	effect_stack = EffectStackEngine.new()
	buff_system = BuffSystem.new()
	card_zones = CardZonesModel.new()
	phase_machine = BattlePhaseStateMachine.new()


func bind_battle_context(character: CharacterStats, hand: Hand) -> void:
	_character = character
	_hand = hand
	card_zones.bind_context(character, hand)
	buff_system.connect_events()


func bind_combatants(player: Player, enemies: Array[Enemy]) -> void:
	_player = player
	_enemies = enemies.duplicate()
	if phase_machine != null:
		phase_machine.bind_context(player, _enemies, self)


func unbind_battle_context() -> void:
	phase_machine.unbind_context()
	buff_system.disconnect_events()
	card_zones.unbind_context()
	_character = null
	_hand = null
	_player = null
	_enemies.clear()


func is_player_action_window_open() -> bool:
	return card_zones.is_player_action_window_open()


func start_battle() -> void:
	phase_machine.start()


func get_current_turn() -> int:
	return phase_machine.get_turn()


func get_current_phase() -> int:
	return phase_machine.get_phase()


func end_player_turn() -> bool:
	return phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)


func remove_enemy(enemy: Enemy) -> void:
	_enemies.erase(enemy)
	phase_machine.remove_enemy(enemy)
