class_name ShopFlowService
extends RefCounted

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/shop_offer_generator.gd")
const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")

var route_dispatcher: RunRouteDispatcher


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher


func generate_offers(run_state: RunState) -> Array[Dictionary]:
	return SHOP_OFFER_GENERATOR_SCRIPT.generate_offers(run_state)


func execute_buy_offer(run_state: RunState, offers: Array[Dictionary], index: int) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")
	if index < 0 or index >= offers.size():
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")

	var offer := offers[index]
	var card := offer.get("card") as Card
	var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.CARD_BUY_PRICE))

	if not run_state.spend_gold(price):
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "金币不足，无法购买。")

	if not run_state.add_card_to_deck(card):
		# Keep old behavior: refund if add-to-deck fails.
		run_state.add_gold(price)
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：卡牌无效，已退款。")

	offers.remove_at(index)
	return _result(RunRouteDispatcher.ROUTE_SHOP, true, "已购买：%s" % _card_name(card))


func execute_remove_card(run_state: RunState, index: int) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")
	var cards := run_state.get_deck_cards()
	if index < 0 or index >= cards.size():
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "移除卡牌失败。")

	var card := cards[index] as Card
	var remove_price := SHOP_OFFER_GENERATOR_SCRIPT.calculate_remove_price(run_state)
	if not SHOP_OFFER_GENERATOR_SCRIPT.remove_card(run_state, card):
		if run_state.gold < remove_price:
			return _result(RunRouteDispatcher.ROUTE_SHOP, true, "金币不足，无法移除卡牌。")
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "移除卡牌失败。")

	return _result(RunRouteDispatcher.ROUTE_SHOP, true, "已移除：%s" % _card_name(card))


func execute_leave(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")
	run_state.next_floor()
	return _result(RunRouteDispatcher.ROUTE_MAP, true, "")


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.id


func _result(next_route: String, handled: bool, status_text: String) -> Dictionary:
	return route_dispatcher.make_result(next_route, {
		"handled": handled,
		"status_text": status_text,
	})
