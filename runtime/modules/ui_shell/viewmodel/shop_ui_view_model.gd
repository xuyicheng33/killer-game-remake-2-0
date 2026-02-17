class_name ShopUIViewModel
extends RefCounted

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/shop_offer_generator.gd")


func project(run_state: RunState, offers: Array[Dictionary]) -> Dictionary:
	var projection := {
		"gold_text": "金币：--",
		"offer_buttons": [],
		"deck_buttons": [],
	}

	if run_state == null:
		return projection

	projection["gold_text"] = "金币：%d" % run_state.gold
	projection["offer_buttons"] = _project_offers(run_state, offers)
	projection["deck_buttons"] = _project_deck(run_state)

	return projection


func _project_offers(run_state: RunState, offers: Array[Dictionary]) -> Array[Dictionary]:
	var buttons: Array[Dictionary] = []

	for i in range(offers.size()):
		var offer := offers[i]
		var card := offer.get("card") as Card
		var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.BUY_PRICE))

		buttons.append({
			"index": i,
			"text": "购买卡牌：%s（%d 金币）" % [_card_name(card), price],
			"disabled": run_state.gold < price,
		})

	return buttons


func _project_deck(run_state: RunState) -> Array[Dictionary]:
	var buttons: Array[Dictionary] = []

	var cards := run_state.get_deck_cards()
	for i in range(cards.size()):
		var card := cards[i] as Card
		buttons.append({
			"index": i,
			"text": "移除卡牌：%s（%d 金币）" % [_card_name(card), SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE],
			"disabled": run_state.gold < SHOP_OFFER_GENERATOR_SCRIPT.REMOVE_PRICE or cards.size() <= 1,
		})

	return buttons


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.id
