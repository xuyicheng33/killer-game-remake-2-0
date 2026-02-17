class_name ShopFlowService
extends RefCounted

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/shop_offer_generator.gd")


func generate_offers(run_state: RunState) -> Array[Dictionary]:
	return SHOP_OFFER_GENERATOR_SCRIPT.generate_offers(run_state)


func execute_buy_offer(run_state: RunState, offers: Array[Dictionary], index: int) -> Dictionary:
	if run_state == null:
		return _result(false, "")
	if index < 0 or index >= offers.size():
		return _result(false, "")

	var offer := offers[index]
	var card := offer.get("card") as Card
	var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.BUY_PRICE))

	if not run_state.spend_gold(price):
		return _result(true, "金币不足，无法购买。")

	if not run_state.add_card_to_deck(card):
		# Keep old behavior: refund if add-to-deck fails.
		run_state.add_gold(price)
		return _result(true, "购买失败：卡牌无效，已退款。")

	offers.remove_at(index)
	return _result(true, "已购买：%s" % _card_name(card))


func execute_remove_card(run_state: RunState, index: int) -> Dictionary:
	if run_state == null:
		return _result(false, "")

	if not run_state.spend_gold(SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE):
		return _result(true, "金币不足，无法移除卡牌。")

	var removed := run_state.remove_card_from_deck_at(index)
	if removed == null:
		# Keep old behavior: refund if remove fails.
		run_state.add_gold(SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE)
		return _result(true, "移除卡牌失败。")

	return _result(true, "已移除：%s" % _card_name(removed))


func execute_leave(run_state: RunState) -> void:
	if run_state == null:
		return
	run_state.next_floor()


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.id


func _result(handled: bool, status_text: String) -> Dictionary:
	return {
		"handled": handled,
		"status_text": status_text,
	}
