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
	if buff_system != null:
		buff_system.bind_combatants(player, _enemies)


func unbind_battle_context() -> void:
	phase_machine.unbind_context()
	buff_system.disconnect_events()
	buff_system.unbind_combatants()
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
	# 同步更新 BuffSystem 的敌人列表
	if buff_system != null:
		buff_system.remove_enemy(enemy)


func draw_cards(amount: int) -> int:
	if amount <= 0:
		return 0
	if _character == null or _hand == null:
		return 0
	if _character.draw_pile == null:
		_character.draw_pile = CardPile.new()
	if _character.discard == null:
		_character.discard = CardPile.new()

	var drawn := 0
	for _index in range(amount):
		_reshuffle_deck_from_discard("card_effect_draw")
		var card: Card = _character.draw_pile.draw_card()
		if card == null:
			break
		_hand.add_card(card)
		drawn += 1

	return drawn


func gain_mana(amount: int) -> int:
	if amount <= 0:
		return 0
	if _character == null:
		return 0
	var before := _character.mana
	_character.mana = clampi(_character.mana + amount, 0, _character.max_mana)
	return _character.mana - before


func get_player() -> Player:
	return _player


func get_enemies() -> Array[Enemy]:
	return _enemies.duplicate()


func _reshuffle_deck_from_discard(stream_key: String) -> void:
	if _character == null:
		return
	if _character.draw_pile == null or _character.discard == null:
		return
	if not _character.draw_pile.empty():
		return

	while not _character.discard.empty():
		_character.draw_pile.add_card(_character.discard.draw_card())

	_character.draw_pile.shuffle_with_rng(stream_key)
