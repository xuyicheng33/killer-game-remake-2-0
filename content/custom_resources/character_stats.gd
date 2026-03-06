class_name CharacterStats
extends Stats

@export var starting_deck: CardPile
@export var cards_per_turn: int
@export var max_mana: int

var mana: int : set = set_mana
var deck: CardPile
var discard: CardPile
var draw_pile: CardPile


func set_mana(value: int) -> void:
	mana = value
	stats_changed.emit()


func reset_mana() -> void:
	self.mana = max_mana


func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)
	if initial_health > health:
		Events.player_hit.emit()


func can_play_card(card: Card) -> bool:
	return mana >= card.cost


func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate(true) as CharacterStats
	if instance == null:
		instance = CharacterStats.new()
		instance.max_health = max_health
		instance.max_mana = max_mana
		instance.cards_per_turn = cards_per_turn
		instance.art = art
	if _status_container != null:
		instance._status_container = _status_container.duplicate(true)
		instance._status_container.clear_all()
	instance.max_health = maxi(1, instance.max_health)
	instance.health = instance.max_health
	instance.block = 0
	instance.reset_mana()
	var template_deck: CardPile = null
	if instance.starting_deck != null:
		template_deck = instance.starting_deck
	elif deck != null:
		template_deck = deck
	if template_deck != null:
		var duplicated_deck: Variant = template_deck.duplicate(true)
		if duplicated_deck is CardPile:
			instance.deck = duplicated_deck
		else:
			instance.deck = CardPile.new()
	else:
		instance.deck = CardPile.new()
	instance.draw_pile = CardPile.new()
	instance.discard = CardPile.new()
	return instance
