class_name ShopOfferGenerator
extends RefCounted

const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")

const BUY_PRICE := 55
const REMOVE_PRICE := 75
const SHOP_OFFER_COUNT := 3


static func generate_offers(run_state: RunState) -> Array[Dictionary]:
	var pool := REWARD_GENERATOR_SCRIPT.get_card_pool_for_run(run_state)
	var stream_key: String = _shop_stream_key(run_state)
	var cards := REWARD_GENERATOR_SCRIPT.pick_random_cards(pool, SHOP_OFFER_COUNT, stream_key)
	var offers: Array[Dictionary] = []
	for card in cards:
		offers.append({
			"card": card,
			"price": BUY_PRICE,
		})
	return offers


static func _shop_stream_key(run_state: RunState) -> String:
	if run_state == null:
		return "reward:shop_offers:null_run"
	return "reward:shop_offers:seed_%d:floor_%d:node_%s" % [
		run_state.seed,
		run_state.floor,
		run_state.map_current_node_id,
	]
