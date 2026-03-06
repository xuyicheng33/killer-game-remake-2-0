class_name StatusHandler
extends RefCounted

var id: String
var label: String
var on_turn_start: Callable
var on_turn_end: Callable
var on_card_played: Callable
var on_entity_hit: Callable
var decays_on_turn_end := false


static func create(
	p_id: String,
	p_label: String,
	p_on_turn_start: Callable = Callable(),
	p_on_turn_end: Callable = Callable(),
	p_decays_on_turn_end := false,
	p_on_card_played: Callable = Callable(),
	p_on_entity_hit: Callable = Callable()
) -> StatusHandler:
	var handler := StatusHandler.new()
	handler.id = p_id
	handler.label = p_label
	handler.on_turn_start = p_on_turn_start
	handler.on_turn_end = p_on_turn_end
	handler.decays_on_turn_end = p_decays_on_turn_end
	handler.on_card_played = p_on_card_played
	handler.on_entity_hit = p_on_entity_hit
	return handler
