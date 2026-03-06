class_name ShopUIViewModel
extends RefCounted

const SHOP_OFFER_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/shop_offer_generator.gd")

const OFFER_TYPE_CARD := "card"
const OFFER_TYPE_RELIC := "relic"
const OFFER_TYPE_POTION := "potion"


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
		var price := int(offer.get("price", SHOP_OFFER_GENERATOR_SCRIPT.CARD_BUY_PRICE))
		var offer_type := str(offer.get("offer_type", OFFER_TYPE_CARD))
		var label := ""
		var disabled := run_state.gold < price
		var tooltip_title := "商店物品"
		var tooltip_body := ""

		match offer_type:
			OFFER_TYPE_CARD:
				var card: Card = null
				var card_variant: Variant = offer.get("card")
				if card_variant is Card:
					card = card_variant
				label = "购买卡牌：%s（%d 金币）" % [_card_name(card), price]
				tooltip_title = _card_name(card)
				tooltip_body = card.tooltip_text if card != null else ""
			OFFER_TYPE_RELIC:
				var relic: RelicData = null
				var relic_variant: Variant = offer.get("relic")
				if relic_variant is RelicData:
					relic = relic_variant
				label = "购买遗物：%s（%d 金币）" % [_relic_name(relic), price]
				tooltip_title = _relic_name(relic)
				tooltip_body = relic.description if relic != null else ""
				disabled = disabled or run_state.relics.size() >= run_state.relic_capacity
			OFFER_TYPE_POTION:
				var potion: PotionData = null
				var potion_variant: Variant = offer.get("potion")
				if potion_variant is PotionData:
					potion = potion_variant
				label = "购买药水：%s（%d 金币）" % [_potion_name(potion), price]
				tooltip_title = _potion_name(potion)
				tooltip_body = potion.description if potion != null else ""
				disabled = disabled or _is_potion_inventory_full(run_state)
			_:
				label = "购买商品（%d 金币）" % price

		buttons.append({
			"index": i,
			"text": label,
			"disabled": disabled,
			"tooltip_icon": _tooltip_icon_for_offer(offer),
			"tooltip_title": tooltip_title,
			"tooltip_body": tooltip_body,
		})

	return buttons


func _project_deck(run_state: RunState) -> Array[Dictionary]:
	var buttons: Array[Dictionary] = []
	var cards := run_state.get_deck_cards()
	var remove_price := SHOP_OFFER_GENERATOR_SCRIPT.calculate_remove_price_for_shop(run_state)
	for i in range(cards.size()):
		var card: Card = null
		var card_variant: Variant = cards[i]
		if card_variant is Card:
			card = card_variant
		buttons.append({
			"index": i,
			"text": "移除卡牌：%s（%d 金币）" % [_card_name(card), remove_price],
			"disabled": run_state.gold < remove_price or cards.size() <= 1,
		})

	return buttons


func _card_name(card: Card) -> String:
	if card == null:
		return "(空卡)"
	return card.get_display_name()


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


func _is_potion_inventory_full(run_state: RunState) -> bool:
	var capacity := run_state.potion_capacity
	if capacity <= 0:
		capacity = SHOP_OFFER_GENERATOR_SCRIPT.MAX_POTION_INVENTORY
	return run_state.potions.size() >= capacity


func _tooltip_icon_for_offer(offer: Dictionary) -> Texture:
	var card_variant: Variant = offer.get("card")
	if card_variant is Card and card_variant.icon != null:
		return card_variant.icon
	return null
