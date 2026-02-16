class_name ShopOfferGenerator
extends RefCounted

const REWARD_GENERATOR_SCRIPT := preload("res://modules/reward_economy/reward_generator.gd")

const BUY_PRICE := 55
const REMOVE_PRICE := 75
const SHOP_OFFER_COUNT := 3


static func generate_offers(run_state: RunState) -> Array[Dictionary]:
	var pool := REWARD_GENERATOR_SCRIPT.get_card_pool_for_run(run_state)
	var cards := REWARD_GENERATOR_SCRIPT.pick_random_cards(pool, SHOP_OFFER_COUNT)
	var offers: Array[Dictionary] = []
	for card in cards:
		offers.append({
			"card": card,
			"price": BUY_PRICE,
		})
	return offers
