class_name ShopScreen
extends Control

signal shop_completed

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/shop_offer_generator.gd")
const SHOP_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/shop_flow_service.gd")

@export var run_state: RunState

@onready var content_margin: MarginContainer = %MarginContainer
@onready var gold_label: Label = %GoldLabel
@onready var offers_container: VBoxContainer = %OffersContainer
@onready var deck_container: VBoxContainer = %DeckContainer
@onready var status_label: Label = %StatusLabel
@onready var leave_button: Button = %LeaveButton

var _offers: Array[Dictionary] = []
var flow_service: ShopFlowService


func _ready() -> void:
	if flow_service == null:
		flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService

	_apply_responsive_layout()
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	leave_button.pressed.connect(_on_leave_pressed)
	_offers = flow_service.generate_offers(run_state)
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
	if flow_service == null:
		return

	var result := flow_service.execute_buy_offer(run_state, _offers, index)
	if not bool(result.get("handled", false)):
		return

	status_label.text = str(result.get("status_text", ""))
	_refresh()


func _on_remove_card(index: int) -> void:
	if flow_service == null:
		return

	var result := flow_service.execute_remove_card(run_state, index)
	if not bool(result.get("handled", false)):
		return

	status_label.text = str(result.get("status_text", ""))
	_refresh()


func _on_leave_pressed() -> void:
	if flow_service == null:
		flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService

	flow_service.execute_leave(run_state)
	shop_completed.emit()


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.id


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	var horizontal_margin := clampf(viewport_size.x * 0.04, 16.0, 120.0)
	var vertical_margin := clampf(viewport_size.y * 0.05, 14.0, 84.0)
	var reserved_overlay_width := clampf(viewport_size.x * 0.23, 280.0, 460.0)

	content_margin.offset_left = horizontal_margin
	content_margin.offset_top = vertical_margin
	content_margin.offset_right = -(horizontal_margin + reserved_overlay_width)
	content_margin.offset_bottom = -vertical_margin

	var content_width := viewport_size.x + content_margin.offset_right - content_margin.offset_left
	if content_width < 760.0:
		content_margin.offset_right = -horizontal_margin
