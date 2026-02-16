class_name ShopScreen
extends Control

signal shop_completed

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://modules/reward_economy/shop_offer_generator.gd")

@export var run_state: RunState

@onready var gold_label: Label = %GoldLabel
@onready var offers_container: VBoxContainer = %OffersContainer
@onready var deck_container: VBoxContainer = %DeckContainer
@onready var status_label: Label = %StatusLabel
@onready var leave_button: Button = %LeaveButton

var _offers: Array[Dictionary] = []


func _ready() -> void:
	leave_button.pressed.connect(_on_leave_pressed)
	_offers = SHOP_OFFER_GENERATOR_SCRIPT.generate_offers(run_state)
	_refresh()


func _refresh() -> void:
	if run_state:
		gold_label.text = "金币：%d" % run_state.gold
	else:
		gold_label.text = "金币：--"
	_render_offers()
	_render_deck_ops()


func _render_offers() -> void:
	for child in offers_container.get_children():
		child.queue_free()

	for i in range(_offers.size()):
		var offer := _offers[i]
		var card := offer.get("card") as Card
		var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.BUY_PRICE))
		var btn := Button.new()
		btn.text = "购买卡牌：%s（%d 金币）" % [_card_name(card), price]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 64)
		btn.disabled = run_state == null or run_state.gold < price
		btn.pressed.connect(_on_buy_offer.bind(i))
		offers_container.add_child(btn)


func _render_deck_ops() -> void:
	for child in deck_container.get_children():
		child.queue_free()

	if run_state == null:
		return

	var cards := run_state.get_deck_cards()
	for i in range(cards.size()):
		var card := cards[i] as Card
		var btn := Button.new()
		btn.text = "移除卡牌：%s（%d 金币）" % [_card_name(card), SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 64)
		btn.disabled = run_state.gold < SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE or cards.size() <= 1
		btn.pressed.connect(_on_remove_card.bind(i))
		deck_container.add_child(btn)


func _on_buy_offer(index: int) -> void:
	if run_state == null:
		return
	if index < 0 or index >= _offers.size():
		return

	var offer := _offers[index]
	var card := offer.get("card") as Card
	var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.BUY_PRICE))
	if not run_state.spend_gold(price):
		status_label.text = "金币不足，无法购买。"
		_refresh()
		return

	if not run_state.add_card_to_deck(card):
		# Refund when add-to-deck fails (e.g. invalid card data).
		run_state.add_gold(price)
		status_label.text = "购买失败：卡牌无效，已退款。"
		_refresh()
		return

	status_label.text = "已购买：%s" % _card_name(card)
	_offers.remove_at(index)
	_refresh()


func _on_remove_card(index: int) -> void:
	if run_state == null:
		return
	if not run_state.spend_gold(SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE):
		status_label.text = "金币不足，无法移除卡牌。"
		_refresh()
		return

	var removed := run_state.remove_card_from_deck_at(index)
	if removed == null:
		# Refund when remove fails.
		run_state.add_gold(SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE)
		status_label.text = "移除卡牌失败。"
	else:
		status_label.text = "已移除：%s" % _card_name(removed)

	_refresh()


func _on_leave_pressed() -> void:
	if run_state:
		run_state.next_floor()
	shop_completed.emit()


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.id
