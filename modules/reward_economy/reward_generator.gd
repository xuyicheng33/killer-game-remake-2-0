class_name RewardGenerator
extends RefCounted

const REWARD_BUNDLE_SCRIPT := preload("res://modules/reward_economy/reward_bundle.gd")

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
	return bundle


static func apply_post_battle_reward(run_state: RunState, bundle: RewardBundle, chosen_card: Card) -> void:
	if run_state == null:
		return
	if bundle != null:
		run_state.add_gold(bundle.gold)

	# Deck currently lives on `run_state.player_stats.deck` in this codebase.
	if chosen_card != null and run_state.player_stats != null and run_state.player_stats.deck != null:
		run_state.player_stats.deck.add_card(chosen_card.duplicate(true))

	run_state.next_floor()


static func _get_pool_for_run(_run_state: RunState) -> Array[Card]:
	# Placeholder for future: choose pool by character/class.
	return WARRIOR_POOL


static func get_card_pool_for_run(run_state: RunState) -> Array[Card]:
	return _get_pool_for_run(run_state)


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
