class_name RunStateCommandService
extends RefCounted


func enter_map_node(run_state: RunState, node_id: String) -> bool:
	if run_state == null:
		return false
	return run_state.enter_map_node(node_id)


func next_floor(run_state: RunState) -> void:
	if run_state == null:
		return
	run_state.next_floor()


func add_gold(run_state: RunState, amount: int) -> void:
	if run_state == null:
		return
	run_state.add_gold(amount)


func spend_gold(run_state: RunState, amount: int) -> bool:
	if run_state == null:
		return false
	return run_state.spend_gold(amount)


func heal_player(run_state: RunState, amount: int) -> void:
	if run_state == null:
		return
	run_state.heal_player(amount)


func increase_max_health(run_state: RunState, amount: int) -> void:
	if run_state == null:
		return
	run_state.increase_max_health(amount)


func add_card_to_deck(run_state: RunState, card: Card) -> bool:
	if run_state == null:
		return false
	return run_state.add_card_to_deck(card)


func remove_card_from_deck_at(run_state: RunState, index: int) -> Card:
	if run_state == null:
		return null
	return run_state.remove_card_from_deck_at(index)


func upgrade_card_in_deck_at(run_state: RunState, index: int) -> bool:
	if run_state == null:
		return false
	return run_state.upgrade_card_in_deck_at(index)


func add_relic(run_state: RunState, relic: RelicData) -> bool:
	if run_state == null:
		return false
	return run_state.add_relic(relic)


func add_potion(run_state: RunState, potion: PotionData) -> bool:
	if run_state == null:
		return false
	return run_state.add_potion(potion)
