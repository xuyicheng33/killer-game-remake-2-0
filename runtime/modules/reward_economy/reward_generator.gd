class_name RewardGenerator
extends RefCounted

const REWARD_BUNDLE_SCRIPT := preload("res://runtime/modules/reward_economy/reward_bundle.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const SAMPLE_RELIC := preload("res://content/custom_resources/relics/ember_ring.tres")
const SAMPLE_POTION := preload("res://content/custom_resources/potions/healing_potion.tres")
const SAMPLE_POTION_ALT := preload("res://content/custom_resources/potions/iron_skin_potion.tres")

# Minimal card pool for Phase B / B1: Warrior only.
const WARRIOR_POOL: Array[Card] = [
	preload("res://content/characters/warrior/cards/generated/warrior_slash.tres"),
	preload("res://content/characters/warrior/cards/generated/warrior_block.tres"),
	preload("res://content/characters/warrior/cards/generated/warrior_axe_attack.tres"),
]


static func generate_post_battle_reward(run_state: RunState, gold_amount: int) -> RewardBundle:
	var bundle := REWARD_BUNDLE_SCRIPT.new() as RewardBundle
	bundle.gold = maxi(0, gold_amount)
	var stream_key: String = _reward_stream_key(run_state, "post_battle_cards")
	bundle.card_choices = pick_random_cards(get_card_pool_for_run(run_state), 3, stream_key)
	if run_state != null:
		if run_state.floor % 2 == 0:
			bundle.potion_reward = SAMPLE_POTION
		else:
			bundle.relic_reward = SAMPLE_RELIC
	return bundle


static func apply_post_battle_reward(run_state: RunState, bundle: RewardBundle, chosen_card: Card) -> String:
	if run_state == null:
		return ""

	var logs: PackedStringArray = []
	if bundle == null:
		run_state.next_floor()
		return ""

	run_state.add_gold(bundle.gold)
	logs.append("金币 +%d" % bundle.gold)

	if chosen_card != null:
		if run_state.add_card_to_deck(chosen_card):
			logs.append("加入卡牌：%s" % chosen_card.id)
		else:
			logs.append("加入卡牌失败：%s" % chosen_card.id)

	if bundle.relic_reward != null:
		if run_state.add_relic(bundle.relic_reward):
			logs.append("获得遗物：%s" % bundle.relic_reward.title)
		else:
			run_state.add_gold(20)
			logs.append("遗物栏已满，改为金币 +20")

	if bundle.potion_reward != null:
		if run_state.add_potion(bundle.potion_reward):
			logs.append("获得药水：%s" % bundle.potion_reward.title)
		else:
			run_state.add_gold(15)
			logs.append("药水栏已满，改为金币 +15")

	run_state.next_floor()
	return "；".join(logs)


static func _get_pool_for_run(_run_state: RunState) -> Array[Card]:
	# Placeholder for future: choose pool by character/class.
	return WARRIOR_POOL


static func get_card_pool_for_run(run_state: RunState) -> Array[Card]:
	return _get_pool_for_run(run_state)


static func generate_b3_bonus(node_type: MapNodeData.NodeType) -> Dictionary:
	var bonus := {
		"relic": null,
		"potion": null,
	}
	match node_type:
		MapNodeData.NodeType.SHOP:
			bonus["relic"] = SAMPLE_RELIC
		MapNodeData.NodeType.EVENT:
			# Alternate potion sample to make B3 chain observable.
			bonus["potion"] = SAMPLE_POTION_ALT
		_:
			pass
	return bonus


static func apply_b3_bonus(run_state: RunState, bonus: Dictionary) -> String:
	if run_state == null:
		return ""

	var logs: PackedStringArray = []
	var relic := bonus.get("relic") as RelicData
	var potion := bonus.get("potion") as PotionData

	if relic != null:
		if run_state.add_relic(relic):
			logs.append("节点奖励：获得遗物 %s" % relic.title)
		else:
			run_state.add_gold(20)
			logs.append("节点奖励遗物溢出，改为金币 +20")

	if potion != null:
		if run_state.add_potion(potion):
			logs.append("节点奖励：获得药水 %s" % potion.title)
		else:
			run_state.add_gold(15)
			logs.append("节点奖励药水溢出，改为金币 +15")

	return "；".join(logs)


static func pick_random_cards_with_stream(pool: Array[Card], count: int, stream_key: String) -> Array[Card]:
	var out: Array[Card] = []
	if count <= 0:
		return out
	if pool == null or pool.is_empty():
		return out

	# Prefer distinct picks when possible; fall back to repeats if pool < count.
	var available := pool.duplicate()
	while out.size() < count and not available.is_empty():
		var index: int = RUN_RNG_SCRIPT.pick_index("%s:distinct" % stream_key, available.size())
		if index < 0:
			break
		var picked := available[index] as Card
		available.remove_at(index)
		if picked != null:
			out.append(picked)

	var fallback_guard := 0
	while out.size() < count:
		var fallback_index: int = RUN_RNG_SCRIPT.pick_index("%s:fallback" % stream_key, pool.size())
		if fallback_index < 0:
			break
		var fallback_card := pool[fallback_index] as Card
		if fallback_card != null:
			out.append(fallback_card)
			continue

		fallback_guard += 1
		if fallback_guard > pool.size():
			break

	return out


static func pick_random_cards(pool: Array[Card], count: int, stream_key: String) -> Array[Card]:
	return pick_random_cards_with_stream(pool, count, stream_key)


static func pick_random_card(pool: Array[Card], stream_key: String) -> Card:
	if pool == null or pool.is_empty():
		return null
	var index: int = RUN_RNG_SCRIPT.pick_index(stream_key, pool.size())
	if index < 0:
		return null
	return pool[index] as Card


static func _reward_stream_key(run_state: RunState, suffix: String) -> String:
	if run_state == null:
		return "reward:%s:null_run" % suffix
	return "reward:%s:seed_%d:floor_%d:node_%s" % [
		suffix,
		run_state.seed,
		run_state.floor,
		run_state.map_current_node_id,
	]
