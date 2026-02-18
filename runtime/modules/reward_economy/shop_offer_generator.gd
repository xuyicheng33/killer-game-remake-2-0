class_name ShopOfferGenerator
extends RefCounted

const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")
const RELIC_CATALOG_SCRIPT := preload("res://runtime/modules/relic_potion/relic_catalog.gd")
const POTION_CATALOG_SCRIPT := preload("res://runtime/modules/relic_potion/potion_catalog.gd")

const CARD_BUY_PRICE := 55
const REMOVE_BASE_PRICE := 75
const REMOVE_PRICE_INCREASE := 25
const POTION_BUY_PRICE := 50
const SHOP_CARD_COUNT := 3
const SHOP_RELIC_COUNT := 1
const SHOP_POTION_COUNT := 1


static func generate_offers(run_state: RunState) -> Array[Dictionary]:
	var pool := RewardGenerator.get_card_pool_for_run(run_state)
	var stream_key: String = _shop_stream_key(run_state)
	var cards := RewardGenerator.pick_random_cards(pool, SHOP_CARD_COUNT, stream_key)
	var offers: Array[Dictionary] = []
	for card in cards:
		offers.append({
			"card": card,
			"price": CARD_BUY_PRICE,
		})
	return offers


static func generate_full_offers(run_state: RunState) -> Dictionary:
	var stream_key := _shop_stream_key(run_state)
	
	var card_offers := _generate_card_offers(run_state, stream_key)
	var relic_offers := _generate_relic_offers(run_state, stream_key)
	var potion_offers := _generate_potion_offers(run_state, stream_key)
	var remove_price := calculate_remove_price(run_state)
	
	return {
		"cards": card_offers,
		"relics": relic_offers,
		"potions": potion_offers,
		"remove_price": remove_price,
	}


static func _generate_card_offers(run_state: RunState, stream_key: String) -> Array[Dictionary]:
	var pool := RewardGenerator.get_card_pool_for_run(run_state)
	var cards := RewardGenerator.pick_random_cards(pool, SHOP_CARD_COUNT, stream_key + ":cards")
	var offers: Array[Dictionary] = []
	for card in cards:
		var price := _card_price(card)
		offers.append({
			"card": card,
			"price": price,
		})
	return offers


static func _generate_relic_offers(run_state: RunState, stream_key: String) -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	
	for i in range(SHOP_RELIC_COUNT):
		var relic := RELIC_CATALOG_SCRIPT.pick_random(stream_key + ":relic:%d" % i)
		if relic != null:
			var price := _relic_price(relic)
			offers.append({
				"relic": relic,
				"price": price,
			})
	
	return offers


static func _generate_potion_offers(run_state: RunState, stream_key: String) -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	
	for i in range(SHOP_POTION_COUNT):
		var potion := POTION_CATALOG_SCRIPT.pick_random(stream_key + ":potion:%d" % i)
		if potion != null:
			offers.append({
				"potion": potion,
				"price": POTION_BUY_PRICE,
			})
	
	return offers


static func _card_price(_card: Card) -> int:
	return CARD_BUY_PRICE


static func _relic_price(relic: RelicData) -> int:
	if relic == null:
		return 150
	
	match relic.rarity:
		"common": return 150
		"uncommon": return 200
		"rare": return 300
		_: return 150


static func calculate_remove_price(run_state: RunState) -> int:
	if run_state == null:
		return REMOVE_BASE_PRICE
	
	var remove_count := run_state.card_removal_count if run_state.has_method("get") else 0
	return REMOVE_BASE_PRICE + (remove_count * REMOVE_PRICE_INCREASE)


static func _shop_stream_key(run_state: RunState) -> String:
	if run_state == null:
		return "reward:shop_offers:null_run"
	return "reward:shop_offers:seed_%d:floor_%d:node_%s" % [
		run_state.seed,
		run_state.floor,
		run_state.map_current_node_id,
	]


static func buy_card(run_state: RunState, card: Card, price: int) -> bool:
	if run_state == null or card == null:
		return false
	if run_state.gold < price:
		return false
	
	run_state.add_gold(-price)
	run_state.deck.add_card(card)
	return true


static func buy_relic(run_state: RunState, relic: RelicData, price: int) -> bool:
	if run_state == null or relic == null:
		return false
	if run_state.gold < price:
		return false
	
	run_state.add_gold(-price)
	run_state.relics.append(relic)
	return true


static func buy_potion(run_state: RunState, potion: PotionData, price: int) -> bool:
	if run_state == null or potion == null:
		return false
	if run_state.gold < price:
		return false
	if run_state.potions.size() >= 3:
		return false
	
	run_state.add_gold(-price)
	run_state.potions.append(potion)
	return true


static func remove_card(run_state: RunState, card: Card) -> bool:
	if run_state == null or card == null:
		return false
	
	var price := calculate_remove_price(run_state)
	if run_state.gold < price:
		return false
	
	if run_state.deck == null:
		return false
	
	if not run_state.deck.remove_card(card):
		return false
	
	run_state.add_gold(-price)
	
	if run_state.has_method("increment_card_removal_count"):
		run_state.increment_card_removal_count()
	
	return true
