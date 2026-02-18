class_name BattleContext
extends RefCounted

var effect_stack: EffectStackEngine
var buff_system: BuffSystem
var card_zones: CardZonesModel
var _character: CharacterStats
var _hand: Hand


func _init() -> void:
	effect_stack = EffectStackEngine.new()
	buff_system = BuffSystem.new()
	card_zones = CardZonesModel.new()


func bind_battle_context(character: CharacterStats, hand: Hand) -> void:
	_character = character
	_hand = hand
	card_zones.bind_context(character, hand)
	buff_system.connect_events()


func unbind_battle_context() -> void:
	buff_system.disconnect_events()
	card_zones.unbind_context()
	_character = null
	_hand = null


func is_player_action_window_open() -> bool:
	return card_zones.is_player_action_window_open()
