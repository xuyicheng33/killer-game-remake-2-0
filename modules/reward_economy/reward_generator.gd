class_name RewardGenerator
extends RefCounted

const REWARD_BUNDLE_SCRIPT := preload("res://modules/reward_economy/reward_bundle.gd")
const SAMPLE_RELIC := preload("res://custom_resources/relics/ember_ring.tres")
const SAMPLE_POTION := preload("res://custom_resources/potions/healing_potion.tres")
const SAMPLE_POTION_ALT := preload("res://custom_resources/potions/iron_skin_potion.tres")

# Minimal card pool for Phase B / B1: Warrior only.
const WARRIOR_POOL: Array[Card] = [
	preload("res://characters/warrior/cards/warrior_slash.tres"),
	preload("res://characters/warrior/cards/warrior_block.tres"),
	preload("res://characters/warrior/cards/warrior_axe_attack.tres"),
]


static func generate_post_battle_reward(run_state: RunState, gold_amount: int) -> RewardBundle:
	var bundle := REWARD_BUNDLE_SCRIPT.new() as RewardBundle
	bundle.gold = maxi(0, gold_amount)
	bundle.card_choices = pick_random_cards(get_card_pool_for_run(run_state), 3)
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


static func pick_random_cards(pool: Array[Card], count: int) -> Array[Card]:
	var out: Array[Card] = []
	if count <= 0:
		return out
	if pool == null or pool.is_empty():
		return out

	# Prefer distinct picks when possible; fall back to repeats if pool < count.
	var available := pool.duplicate()
	available.shuffle()
	while out.size() < count and not available.is_empty():
		out.append(available.pop_front())

	while out.size() < count:
		out.append(pool.pick_random())

	return out
