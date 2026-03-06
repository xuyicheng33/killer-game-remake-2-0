class_name CardZonesModel
extends RefCounted

signal zone_counts_changed(draw_count: int, hand_count: int, discard_count: int, exhaust_count: int)

const HAND_ZONE_PORT_SCRIPT := preload("res://runtime/modules/card_system/hand_zone_port.gd")

var _events_connected := false
var _character: CharacterStats = null
var _hand_port = null
var _exhaust_pile: CardPile = CardPile.new()
var _bound_draw_pile: CardPile = null
var _bound_discard_pile: CardPile = null
var _turn_end_hand_snapshot: Array[Card] = []
var _player_action_window_open := false


func bind_context(character: CharacterStats, hand_port) -> void:
	_disconnect_pile_signals()
	_disconnect_hand_signals()
	_disconnect_events()

	_character = character
	_hand_port = hand_port
	_exhaust_pile = CardPile.new()
	_turn_end_hand_snapshot.clear()
	_player_action_window_open = false

	_connect_events()
	_connect_pile_signals()
	_connect_hand_signals()
	_emit_zone_counts()


func unbind_context() -> void:
	_disconnect_pile_signals()
	_disconnect_hand_signals()
	_disconnect_events()
	_character = null
	if _hand_port != null:
		_hand_port.unbind()
	_hand_port = null
	_exhaust_pile = CardPile.new()
	_turn_end_hand_snapshot.clear()
	_player_action_window_open = false


func is_player_action_window_open() -> bool:
	return _player_action_window_open


func get_draw_count() -> int:
	if _character == null or _character.draw_pile == null:
		return 0
	return _character.draw_pile.size()


func get_hand_count() -> int:
	if _hand_port == null:
		return 0
	return _hand_port.get_count()


func get_discard_count() -> int:
	if _character == null or _character.discard == null:
		return 0
	return _character.discard.size()


func get_exhaust_count() -> int:
	return _exhaust_pile.size()


func get_zone_counts() -> Dictionary:
	return {
		"draw": get_draw_count(),
		"hand": get_hand_count(),
		"discard": get_discard_count(),
		"exhaust": get_exhaust_count(),
	}


func connect_events() -> void:
	_connect_events()


func disconnect_events() -> void:
	_disconnect_events()


func _connect_events() -> void:
	if _events_connected:
		return

	_events_connected = true
	Events.card_played.connect(_on_card_played)
	Events.player_turn_ended.connect(_on_player_turn_ended)
	Events.player_hand_discarded.connect(_on_player_hand_discarded)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)


func _disconnect_events() -> void:
	if not _events_connected:
		return

	_events_connected = false
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_turn_ended.is_connected(_on_player_turn_ended):
		Events.player_turn_ended.disconnect(_on_player_turn_ended)
	if Events.player_hand_discarded.is_connected(_on_player_hand_discarded):
		Events.player_hand_discarded.disconnect(_on_player_hand_discarded)
	if Events.player_hand_drawn.is_connected(_on_player_hand_drawn):
		Events.player_hand_drawn.disconnect(_on_player_hand_drawn)


func _on_card_played(card: Card) -> void:
	if card == null or _character == null:
		return
	call_deferred("_handle_post_card_played", card)


func _handle_post_card_played(card: Card) -> void:
	if _character == null or _character.discard == null:
		return
	if not card.keyword_exhaust:
		_emit_zone_counts()
		return

	var upgraded_card := card.create_exhaust_upgrade_copy()
	if _character.discard.remove_card(card):
		_exhaust_pile.add_card(card)
		if upgraded_card != null:
			_character.discard.add_card(upgraded_card)
	_emit_zone_counts()


func _on_player_turn_ended() -> void:
	_player_action_window_open = false
	_turn_end_hand_snapshot.clear()
	if _hand_port == null:
		return

	_turn_end_hand_snapshot = _hand_port.get_cards()


func _on_player_hand_discarded() -> void:
	if _character == null or _character.discard == null:
		_turn_end_hand_snapshot.clear()
		_emit_zone_counts()
		return

	for card in _turn_end_hand_snapshot:
		if card == null:
			continue

		if card.is_ethereal_card():
			if _character.discard.remove_card(card):
				_exhaust_pile.add_card(card)
			continue

		if card.keyword_retain:
			if _character.discard.remove_card(card):
				if _hand_port != null:
					_hand_port.try_add_card(card)

	_turn_end_hand_snapshot.clear()
	_emit_zone_counts()


func _on_player_hand_drawn() -> void:
	_player_action_window_open = true
	_connect_pile_signals()
	_emit_zone_counts()


func _connect_pile_signals() -> void:
	_disconnect_pile_signals()

	if _character == null:
		return

	if _character.draw_pile != null and not _character.draw_pile.card_pile_size_changed.is_connected(_on_pile_size_changed):
		_character.draw_pile.card_pile_size_changed.connect(_on_pile_size_changed)
		_bound_draw_pile = _character.draw_pile

	if _character.discard != null and not _character.discard.card_pile_size_changed.is_connected(_on_pile_size_changed):
		_character.discard.card_pile_size_changed.connect(_on_pile_size_changed)
		_bound_discard_pile = _character.discard

	if not _exhaust_pile.card_pile_size_changed.is_connected(_on_pile_size_changed):
		_exhaust_pile.card_pile_size_changed.connect(_on_pile_size_changed)


func _disconnect_pile_signals() -> void:
	if _bound_draw_pile != null and _bound_draw_pile.card_pile_size_changed.is_connected(_on_pile_size_changed):
		_bound_draw_pile.card_pile_size_changed.disconnect(_on_pile_size_changed)
	_bound_draw_pile = null

	if _bound_discard_pile != null and _bound_discard_pile.card_pile_size_changed.is_connected(_on_pile_size_changed):
		_bound_discard_pile.card_pile_size_changed.disconnect(_on_pile_size_changed)
	_bound_discard_pile = null

	if _exhaust_pile != null and _exhaust_pile.card_pile_size_changed.is_connected(_on_pile_size_changed):
		_exhaust_pile.card_pile_size_changed.disconnect(_on_pile_size_changed)


func _connect_hand_signals() -> void:
	if _hand_port == null:
		return
	if not _hand_port.cards_changed.is_connected(_on_hand_children_changed):
		_hand_port.cards_changed.connect(_on_hand_children_changed)


func _disconnect_hand_signals() -> void:
	if _hand_port == null:
		return
	if _hand_port.cards_changed.is_connected(_on_hand_children_changed):
		_hand_port.cards_changed.disconnect(_on_hand_children_changed)


func _on_pile_size_changed(_size: int) -> void:
	_emit_zone_counts()


func _on_hand_children_changed() -> void:
	call_deferred("_emit_zone_counts")


func _emit_zone_counts() -> void:
	zone_counts_changed.emit(
		get_draw_count(),
		get_hand_count(),
		get_discard_count(),
		get_exhaust_count()
	)

