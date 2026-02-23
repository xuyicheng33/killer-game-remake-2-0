class_name ShopOfferGenerator
extends RefCounted

const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")
const RELIC_CATALOG_SCRIPT := preload("res://runtime/modules/relic_potion/relic_catalog.gd")
const POTION_CATALOG_SCRIPT := preload("res://runtime/modules/relic_potion/potion_catalog.gd")

const CARD_BUY_PRICE := 55
const REMOVE_BASE_PRICE := 75
const REMOVE_PRICE_INCREASE := 25
const POTION_BUY_PRICE := 50
const MAX_POTION_INVENTORY := 3
const SHOP_CARD_COUNT := 3
const SHOP_RELIC_COUNT := 1
const SHOP_POTION_COUNT := 1
const MAX_SHOP_DISCOUNT_PERCENT := 90
const BUY_PRICE := CARD_BUY_PRICE
const REMOVE_PRICE := REMOVE_BASE_PRICE


static func generate_offers(run_state: RunState) -> Array[Dictionary]:
	var pool := RewardGenerator.get_card_pool_for_run(run_state)
	var stream_key: String = _shop_stream_key(run_state)
	var discount_percent := calculate_shop_discount_percent(run_state)
	var cards := RewardGenerator.pick_random_cards(pool, SHOP_CARD_COUNT, stream_key)
	var offers: Array[Dictionary] = []
	for card in cards:
		var discounted_price := _apply_discount(CARD_BUY_PRICE, discount_percent)
		offers.append({
			"card": card,
			"price": discounted_price,
		})
	return offers


static func generate_full_offers(run_state: RunState) -> Dictionary:
	var stream_key := _shop_stream_key(run_state)
	var discount_percent := calculate_shop_discount_percent(run_state)
	
	var card_offers := _generate_card_offers(run_state, stream_key, discount_percent)
	var relic_offers := _generate_relic_offers(run_state, stream_key, discount_percent)
	var potion_offers := _generate_potion_offers(run_state, stream_key, discount_percent)
	var remove_price := _apply_discount(calculate_remove_price(run_state), discount_percent)
	
	return {
		"cards": card_offers,
		"relics": relic_offers,
		"potions": potion_offers,
		"remove_price": remove_price,
		"discount_percent": discount_percent,
	}


static func _generate_card_offers(run_state: RunState, stream_key: String, discount_percent: int) -> Array[Dictionary]:
	var pool := RewardGenerator.get_card_pool_for_run(run_state)
	var cards := RewardGenerator.pick_random_cards(pool, SHOP_CARD_COUNT, stream_key + ":cards")
	var offers: Array[Dictionary] = []
	for card in cards:
		var price := _apply_discount(_card_price(card), discount_percent)
		offers.append({
			"card": card,
			"price": price,
		})
	return offers


static func _generate_relic_offers(_run_state: RunState, stream_key: String, discount_percent: int) -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	
	for i in range(SHOP_RELIC_COUNT):
		var relic := RELIC_CATALOG_SCRIPT.pick_random(stream_key + ":relic:%d" % i)
		if relic != null:
			var price := _apply_discount(_relic_price(relic), discount_percent)
			offers.append({
				"relic": relic,
				"price": price,
			})
	
	return offers


static func _generate_potion_offers(_run_state: RunState, stream_key: String, discount_percent: int) -> Array[Dictionary]:
	var offers: Array[Dictionary] = []
	
	for i in range(SHOP_POTION_COUNT):
		var potion := POTION_CATALOG_SCRIPT.pick_random(stream_key + ":potion:%d" % i)
		if potion != null:
			offers.append({
				"potion": potion,
				"price": _apply_discount(POTION_BUY_PRICE, discount_percent),
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

	var remove_count := run_state.card_removal_count
	return REMOVE_BASE_PRICE + (remove_count * REMOVE_PRICE_INCREASE)


static func calculate_remove_price_for_shop(run_state: RunState) -> int:
	var base_price := calculate_remove_price(run_state)
	var discount_percent := calculate_shop_discount_percent(run_state)
	return _apply_discount(base_price, discount_percent)


static func calculate_shop_discount_percent(run_state: RunState) -> int:
	if run_state == null:
		return 0

	var total := 0
	for relic_variant in run_state.relics:
		if not (relic_variant is RelicData):
			continue
		var relic: RelicData = relic_variant
		total += maxi(0, relic.shop_discount_percent)

	return clampi(total, 0, MAX_SHOP_DISCOUNT_PERCENT)


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
	if run_state.player_stats == null or run_state.player_stats.deck == null:
		return false

	run_state.add_gold(-price)
	run_state.player_stats.deck.add_card(card.duplicate(true))
	run_state.emit_changed()
	return true


static func buy_relic(run_state: RunState, relic: RelicData, price: int) -> bool:
	if run_state == null or relic == null:
		return false
	if run_state.gold < price:
		return false

	run_state.add_gold(-price)
	if run_state.add_relic(relic):
		return true

	# add_relic 失败时退款，避免吞金币。
	run_state.add_gold(price)
	return false


static func buy_potion(run_state: RunState, potion: PotionData, price: int) -> bool:
	if run_state == null or potion == null:
		return false
	if run_state.gold < price:
		return false
	var potion_capacity := run_state.potion_capacity
	if potion_capacity <= 0:
		potion_capacity = MAX_POTION_INVENTORY
	if run_state.potions.size() >= potion_capacity:
		return false

	run_state.add_gold(-price)
	if run_state.add_potion(potion):
		return true

	# add_potion 失败时退款，避免吞金币。
	run_state.add_gold(price)
	return false


static func remove_card(run_state: RunState, card: Card) -> bool:
	if run_state == null or card == null:
		return false
	
	var price := calculate_remove_price_for_shop(run_state)
	if run_state.gold < price:
		return false
	
	if run_state.player_stats == null or run_state.player_stats.deck == null:
		return false
	
	if not run_state.player_stats.deck.remove_card(card):
		return false
	
	run_state.add_gold(-price)
	run_state.increment_card_removal_count()
	
	return true


static func _apply_discount(price: int, discount_percent: int) -> int:
	var clamped_price := maxi(0, price)
	var clamped_discount := clampi(discount_percent, 0, MAX_SHOP_DISCOUNT_PERCENT)
	if clamped_discount == 0:
		return clamped_price
	var discounted := int(round(float(clamped_price) * float(100 - clamped_discount) / 100.0))
	if clamped_price > 0:
		return maxi(1, discounted)
	return 0
