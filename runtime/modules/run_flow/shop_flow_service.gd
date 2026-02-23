class_name ShopFlowService
extends RefCounted

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/shop_offer_generator.gd")
const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")
const RUN_STATE_COMMAND_SERVICE_SCRIPT := preload("res://runtime/modules/run_meta/run_state_command_service.gd")

const OFFER_TYPE_CARD := "card"
const OFFER_TYPE_RELIC := "relic"
const OFFER_TYPE_POTION := "potion"

var route_dispatcher: RunRouteDispatcher
var _commands


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher
	_commands = RUN_STATE_COMMAND_SERVICE_SCRIPT.new()


func generate_offers(run_state: RunState) -> Array[Dictionary]:
	return _flatten_offers(SHOP_OFFER_GENERATOR_SCRIPT.generate_full_offers(run_state))


func execute_buy_offer(run_state: RunState, offers: Array[Dictionary], index: int) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")
	if index < 0 or index >= offers.size():
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")

	var offer := offers[index]
	var offer_type := str(offer.get("offer_type", OFFER_TYPE_CARD))
	var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.CARD_BUY_PRICE))

	match offer_type:
		OFFER_TYPE_CARD:
			var card: Card = null
			var card_variant: Variant = offer.get("card")
			if card_variant is Card:
				card = card_variant
			if card == null:
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：卡牌数据无效。")
			if not _commands.spend_gold(run_state, price):
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "金币不足，无法购买。")
			if not _commands.add_card_to_deck(run_state, card):
				_commands.add_gold(run_state, price)
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：卡牌无效，已退款。")
			offers.remove_at(index)
			return _result(RunRouteDispatcher.ROUTE_SHOP, true, "已购买卡牌：%s" % _card_name(card))

		OFFER_TYPE_RELIC:
			var relic: RelicData = null
			var relic_variant: Variant = offer.get("relic")
			if relic_variant is RelicData:
				relic = relic_variant
			if relic == null:
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：遗物数据无效。")
			if not SHOP_OFFER_GENERATOR_SCRIPT.buy_relic(run_state, relic, price):
				if run_state.gold < price:
					return _result(RunRouteDispatcher.ROUTE_SHOP, true, "金币不足，无法购买遗物。")
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：遗物栏已满或数据无效。")
			offers.remove_at(index)
			return _result(RunRouteDispatcher.ROUTE_SHOP, true, "已购买遗物：%s" % _relic_name(relic))

		OFFER_TYPE_POTION:
			var potion: PotionData = null
			var potion_variant: Variant = offer.get("potion")
			if potion_variant is PotionData:
				potion = potion_variant
			if potion == null:
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：药水数据无效。")
			if not SHOP_OFFER_GENERATOR_SCRIPT.buy_potion(run_state, potion, price):
				if run_state.gold < price:
					return _result(RunRouteDispatcher.ROUTE_SHOP, true, "金币不足，无法购买药水。")
				return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：药水栏已满或数据无效。")
			offers.remove_at(index)
			return _result(RunRouteDispatcher.ROUTE_SHOP, true, "已购买药水：%s" % _potion_name(potion))

		_:
			return _result(RunRouteDispatcher.ROUTE_SHOP, true, "购买失败：未知商品类型。")


func execute_remove_card(run_state: RunState, index: int) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")
	var cards := run_state.get_deck_cards()
	if index < 0 or index >= cards.size():
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "移除卡牌失败。")

	var card: Card = null
	var card_variant: Variant = cards[index]
	if card_variant is Card:
		card = card_variant
	if card == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "移除卡牌失败：卡牌数据无效。")
	var remove_price := SHOP_OFFER_GENERATOR_SCRIPT.calculate_remove_price_for_shop(run_state)
	if not SHOP_OFFER_GENERATOR_SCRIPT.remove_card(run_state, card):
		if run_state.gold < remove_price:
			return _result(RunRouteDispatcher.ROUTE_SHOP, true, "金币不足，无法移除卡牌。")
		return _result(RunRouteDispatcher.ROUTE_SHOP, true, "移除卡牌失败。")

	return _result(RunRouteDispatcher.ROUTE_SHOP, true, "已移除：%s" % _card_name(card))


func execute_leave(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_SHOP, false, "")
	_commands.next_floor(run_state)
	return _result(RunRouteDispatcher.ROUTE_MAP, true, "")


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.id


func _relic_name(relic: RelicData) -> String:
	if relic == null:
		return "(空遗物)"
	if not relic.title.is_empty():
		return relic.title
	return relic.id


func _potion_name(potion: PotionData) -> String:
	if potion == null:
		return "(空药水)"
	if not potion.title.is_empty():
		return potion.title
	return potion.id


func _flatten_offers(full_offers: Dictionary) -> Array[Dictionary]:
	var flattened: Array[Dictionary] = []

	var cards_variant: Variant = full_offers.get("cards", [])
	if cards_variant is Array:
		var cards: Array = cards_variant
		for offer_variant in cards:
			if not (offer_variant is Dictionary):
				continue
			var offer: Dictionary = (offer_variant as Dictionary).duplicate(true)
			offer["offer_type"] = OFFER_TYPE_CARD
			flattened.append(offer)

	var relics_variant: Variant = full_offers.get("relics", [])
	if relics_variant is Array:
		var relics: Array = relics_variant
		for offer_variant in relics:
			if not (offer_variant is Dictionary):
				continue
			var offer: Dictionary = (offer_variant as Dictionary).duplicate(true)
			offer["offer_type"] = OFFER_TYPE_RELIC
			flattened.append(offer)

	var potions_variant: Variant = full_offers.get("potions", [])
	if potions_variant is Array:
		var potions: Array = potions_variant
		for offer_variant in potions:
			if not (offer_variant is Dictionary):
				continue
			var offer: Dictionary = (offer_variant as Dictionary).duplicate(true)
			offer["offer_type"] = OFFER_TYPE_POTION
			flattened.append(offer)

	return flattened


func _result(next_route: String, handled: bool, status_text: String) -> Dictionary:
	return route_dispatcher.make_result(next_route, {
		"handled": handled,
		"status_text": status_text,
	})
