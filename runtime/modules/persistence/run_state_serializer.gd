class_name RunStateSerializer
extends RefCounted


static func serialize_run_state(run_state: RunState, save_version: int, rng_state: Dictionary) -> Dictionary:
	var payload: Dictionary = {}
	payload["save_version"] = save_version
	payload["character_id"] = run_state.character_id
	payload["seed"] = run_state.run_seed
	payload["act"] = run_state.act
	payload["floor"] = run_state.current_floor
	payload["gold"] = run_state.gold
	payload["relic_capacity"] = run_state.relic_capacity
	payload["potion_capacity"] = run_state.potion_capacity
	payload["map_current_node_id"] = run_state.map_current_node_id
	payload["map_reachable_node_ids"] = packed_string_array_to_array(run_state.map_reachable_node_ids)
	payload["map_visited_node_ids"] = packed_string_array_to_array(run_state.map_visited_node_ids)
	payload["map_graph"] = serialize_map_graph(run_state.map_graph)
	payload["player_stats"] = serialize_player_stats(run_state.player_stats)
	payload["relics"] = serialize_relics(run_state.relics)
	payload["potions"] = serialize_potions(run_state.potions)
	payload["run_start_relics_applied"] = run_state.run_start_relics_applied
	payload["card_removal_count"] = run_state.card_removal_count
	payload["rng_state"] = rng_state
	return payload


static func serialize_player_stats(stats: CharacterStats) -> Dictionary:
	if stats == null:
		return {}

	var deck_data: Array[Dictionary] = []
	if stats.deck != null:
		for card_variant in stats.deck.cards:
			var card := card_variant as Card
			if card == null:
				continue
			deck_data.append(serialize_card(card))

	var data: Dictionary = {}
	data["health"] = stats.health
	data["max_health"] = stats.max_health
	data["mana"] = stats.mana
	data["max_mana"] = stats.max_mana
	data["block"] = stats.block
	data["cards_per_turn"] = stats.cards_per_turn
	data["deck"] = deck_data
	data["statuses"] = stats.get_status_snapshot()
	return data


static func serialize_card(card: Card) -> Dictionary:
	var script_path: String = ""
	var script_variant: Variant = card.get_script()
	if script_variant is Script:
		var card_script: Script = script_variant
		script_path = card_script.resource_path

	var icon_path: String = ""
	if card.icon != null:
		icon_path = card.icon.resource_path

	var sound_path: String = ""
	if card.sound != null:
		sound_path = card.sound.resource_path

	var data: Dictionary = {}
	data["script_path"] = script_path
	data["id"] = card.id
	data["display_name"] = card.display_name
	data["type"] = int(card.type)
	data["target"] = int(card.target)
	data["cost"] = card.cost
	data["keyword_exhaust"] = card.keyword_exhaust
	data["keyword_retain"] = card.keyword_retain
	data["keyword_void"] = card.keyword_void
	data["keyword_ethereal"] = card.keyword_ethereal
	data["keyword_x_cost"] = card.keyword_x_cost
	data["upgrade_to"] = card.upgrade_to
	data["tooltip_text"] = card.tooltip_text
	data["icon_path"] = icon_path
	data["sound_path"] = sound_path
	return data


static func serialize_map_graph(map_graph: MapGraphData) -> Dictionary:
	if map_graph == null:
		return {}

	var nodes: Array[Dictionary] = []
	for node_variant in map_graph.nodes:
		var node := node_variant as MapNodeData
		if node == null:
			continue

		var node_data: Dictionary = {}
		node_data["id"] = node.id
		node_data["type"] = int(node.type)
		node_data["title"] = node.title
		node_data["description"] = node.description
		node_data["reward_gold"] = node.reward_gold
		node_data["floor_index"] = node.floor_index
		node_data["lane_index"] = node.lane_index
		node_data["next_node_ids"] = packed_string_array_to_array(node.next_node_ids)
		nodes.append(node_data)

	var graph_data: Dictionary = {}
	graph_data["floor_count"] = map_graph.floor_count
	graph_data["nodes"] = nodes
	return graph_data


static func serialize_relics(relics: Array[RelicData]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for relic_variant in relics:
		var relic := relic_variant as RelicData
		if relic == null:
			continue
		var item: Dictionary = {}
		item["id"] = relic.id
		item["title"] = relic.title
		item["description"] = relic.description
		item["on_battle_start_heal"] = relic.on_battle_start_heal
		item["on_card_played_gold"] = relic.on_card_played_gold
		item["card_play_interval"] = relic.card_play_interval
		item["on_player_hit_block"] = relic.on_player_hit_block
		item["on_enemy_killed_gold"] = relic.on_enemy_killed_gold
		item["on_turn_start_block"] = relic.on_turn_start_block
		item["on_turn_end_heal"] = relic.on_turn_end_heal
		item["shop_discount_percent"] = relic.shop_discount_percent
		item["on_run_start_gold"] = relic.on_run_start_gold
		item["on_run_start_max_health"] = relic.on_run_start_max_health
		item["on_turn_start_energy"] = relic.on_turn_start_energy
		item["on_turn_start_damage"] = relic.on_turn_start_damage
		item["on_enemy_killed_strength"] = relic.on_enemy_killed_strength
		item["on_enemy_killed_damage"] = relic.on_enemy_killed_damage
		item["on_enemy_killed_draw"] = relic.on_enemy_killed_draw
		item["on_battle_end_heal_per_kill"] = relic.on_battle_end_heal_per_kill
		item["on_attack_played_strength"] = relic.on_attack_played_strength
		item["attack_play_strength_max"] = relic.attack_play_strength_max
		item["on_run_start_strength"] = relic.on_run_start_strength
		out.append(item)
	return out


static func serialize_potions(potions: Array[PotionData]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for potion_variant in potions:
		var potion := potion_variant as PotionData
		if potion == null:
			continue
		var item: Dictionary = {}
		item["id"] = potion.id
		item["title"] = potion.title
		item["description"] = potion.description
		item["effect_type"] = int(potion.effect_type)
		item["value"] = potion.value
		out.append(item)
	return out


static func packed_string_array_to_array(values: PackedStringArray) -> Array[String]:
	var out: Array[String] = []
	out.assign(values)
	return out
