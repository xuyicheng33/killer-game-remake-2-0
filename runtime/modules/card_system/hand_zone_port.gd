class_name HandZonePort
extends RefCounted

signal cards_changed

var _hand: Node = null


static func from_node(hand: Node) -> HandZonePort:
	var port := HandZonePort.new()
	port.bind(hand)
	return port


func bind(hand: Node) -> void:
	unbind()
	_hand = hand
	if _hand != null and is_instance_valid(_hand):
		if not _hand.child_entered_tree.is_connected(_on_changed):
			_hand.child_entered_tree.connect(_on_changed)
		if not _hand.child_exiting_tree.is_connected(_on_changed):
			_hand.child_exiting_tree.connect(_on_changed)


func unbind() -> void:
	if _hand != null and is_instance_valid(_hand):
		if _hand.child_entered_tree.is_connected(_on_changed):
			_hand.child_entered_tree.disconnect(_on_changed)
		if _hand.child_exiting_tree.is_connected(_on_changed):
			_hand.child_exiting_tree.disconnect(_on_changed)
	_hand = null


func get_count() -> int:
	if _hand == null or not is_instance_valid(_hand):
		return 0
	return _hand.get_child_count()


func get_cards() -> Array[Card]:
	var cards: Array[Card] = []
	if _hand == null or not is_instance_valid(_hand):
		return cards
	for child in _hand.get_children():
		if child == null or not is_instance_valid(child):
			continue
		if not ("card" in child):
			continue
		var card_variant: Variant = child.get("card")
		if card_variant is Card:
			cards.append(card_variant as Card)
	return cards


func try_add_card(card: Card) -> bool:
	if _hand == null or not is_instance_valid(_hand):
		return false
	if not _hand.has_method("add_card"):
		return false
	_hand.add_card(card)
	return true


func _on_changed(_node: Node) -> void:
	cards_changed.emit()
