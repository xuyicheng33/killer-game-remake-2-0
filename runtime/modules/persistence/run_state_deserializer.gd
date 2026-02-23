class_name RunStateDeserializer
extends RefCounted


static func resolve_base_stats(payload: Dictionary, fallback_stats: CharacterStats, character_template_resolver: Callable) -> CharacterStats:
	var resolved: CharacterStats = fallback_stats
	if not character_template_resolver.is_valid():
		return resolved

	var saved_character_id: String = str(payload.get("character_id", "")).strip_edges()
	if saved_character_id.is_empty():
		return resolved

	var resolved_variant: Variant = character_template_resolver.call(saved_character_id)
	if resolved_variant is CharacterStats:
		return resolved_variant as CharacterStats
	return resolved


static func deserialize_run_state(payload: Dictionary, base_stats: CharacterStats, map_generator_script: Script) -> RunState:
	var seed: int = int(payload.get("seed", 0))
	var character_id: String = str(payload.get("character_id", "warrior"))
	var restored := RunState.new()
	restored.init_with_character(base_stats, seed, character_id)

	restored.act = maxi(1, int(payload.get("act", restored.act)))
	restored.floor = maxi(0, int(payload.get("floor", restored.floor)))
	restored.gold = maxi(0, int(payload.get("gold", restored.gold)))
	restored.relic_capacity = maxi(0, int(payload.get("relic_capacity", restored.relic_capacity)))
	restored.potion_capacity = maxi(0, int(payload.get("potion_capacity", restored.potion_capacity)))

	apply_player_stats(restored, payload.get("player_stats", {}))

	var map_graph_data: Dictionary = {}
	var map_graph_variant: Variant = payload.get("map_graph", {})
	if map_graph_variant is Dictionary:
		map_graph_data = map_graph_variant
	var deserialized_graph: MapGraphData = deserialize_map_graph(map_graph_data)
	if deserialized_graph != null:
		restored.map_graph = deserialized_graph
	else:
		restored.map_graph = map_generator_script.create_act1_seed_graph(restored.seed)

	restored.map_current_node_id = str(payload.get("map_current_node_id", ""))
	restored.map_reachable_node_ids = variant_to_packed_string_array(payload.get("map_reachable_node_ids", []))
	restored.map_visited_node_ids = variant_to_packed_string_array(payload.get("map_visited_node_ids", []))
	if restored.map_reachable_node_ids.is_empty() and restored.map_current_node_id.is_empty() and restored.map_graph != null:
		restored.map_reachable_node_ids = restored.map_graph.get_start_node_ids()

	restored.relics = deserialize_relics(payload.get("relics", []))
	restored.potions = deserialize_potions(payload.get("potions", []))
	restored.run_start_relics_applied = bool(payload.get("run_start_relics_applied", restored.floor > 0))
	restored.card_removal_count = maxi(0, int(payload.get("card_removal_count", 0)))
	restored.emit_changed()
	return restored


static func apply_player_stats(restored: RunState, stats_variant: Variant) -> void:
	if restored == null or restored.player_stats == null:
		return
	if typeof(stats_variant) != TYPE_DICTIONARY:
		return

	var stats_data: Dictionary = stats_variant as Dictionary
	var stats: CharacterStats = restored.player_stats

	stats.max_health = maxi(1, int(stats_data.get("max_health", stats.max_health)))
	stats.health = clampi(int(stats_data.get("health", stats.health)), 0, stats.max_health)
	stats.max_mana = maxi(0, int(stats_data.get("max_mana", stats.max_mana)))
	stats.cards_per_turn = maxi(1, int(stats_data.get("cards_per_turn", stats.cards_per_turn)))
	stats.mana = clampi(int(stats_data.get("mana", stats.max_mana)), 0, stats.max_mana)
	stats.block = maxi(0, int(stats_data.get("block", 0)))

	var new_deck := CardPile.new()
	var deck_variant: Variant = stats_data.get("deck", [])
	if typeof(deck_variant) == TYPE_ARRAY:
		var deck_data: Array = deck_variant as Array
		for card_variant in deck_data:
			if typeof(card_variant) != TYPE_DICTIONARY:
				continue
			var card_data: Dictionary = card_variant as Dictionary
			var card: Card = deserialize_card(card_data)
			if card == null:
				continue
			new_deck.add_card(card)

	if new_deck.cards.is_empty() and stats.deck != null:
		var duplicated_deck: Variant = stats.deck.duplicate(true)
		if duplicated_deck is CardPile:
			new_deck = duplicated_deck

	stats.deck = new_deck
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()

	var statuses_variant: Variant = stats_data.get("statuses", {})
	if typeof(statuses_variant) == TYPE_DICTIONARY:
		var statuses_data: Dictionary = statuses_variant as Dictionary
		for status_id: String in statuses_data:
			var stacks: int = int(statuses_data.get(status_id, 0))
			if stacks != 0:
				stats.set_status(status_id, stacks)

	stats.stats_changed.emit()


static func deserialize_card(data: Dictionary) -> Card:
	var script_path: String = str(data.get("script_path", ""))
	var card: Card = null

	if not script_path.is_empty() and ResourceLoader.exists(script_path):
		var card_script_variant: Variant = load(script_path)
		if card_script_variant is Script:
			var card_script: Script = card_script_variant
			var script_instance: Variant = card_script.new()
			if script_instance is Card:
				card = script_instance

	if card == null:
		card = Card.new()

	card.id = str(data.get("id", ""))
	card.display_name = str(data.get("display_name", ""))
	card.type = int(data.get("type", int(Card.Type.ATTACK)))
	card.target = int(data.get("target", int(Card.Target.SELF)))
	card.cost = int(data.get("cost", 0))
	card.keyword_exhaust = bool(data.get("keyword_exhaust", false))
	card.keyword_retain = bool(data.get("keyword_retain", false))
	card.keyword_void = bool(data.get("keyword_void", false))
	card.keyword_ethereal = bool(data.get("keyword_ethereal", false))
	card.keyword_x_cost = bool(data.get("keyword_x_cost", false))
	card.upgrade_to = str(data.get("upgrade_to", ""))
	card.tooltip_text = str(data.get("tooltip_text", ""))

	var icon_path: String = str(data.get("icon_path", ""))
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		var icon_variant: Variant = load(icon_path)
		if icon_variant is Texture2D:
			card.icon = icon_variant

	var sound_path: String = str(data.get("sound_path", ""))
	if not sound_path.is_empty() and ResourceLoader.exists(sound_path):
		var audio_variant: Variant = load(sound_path)
		if audio_variant is AudioStream:
			card.sound = audio_variant

	return card


static func deserialize_map_graph(data: Dictionary) -> MapGraphData:
	if data.is_empty():
		return null

	var nodes_variant: Variant = data.get("nodes", [])
	if typeof(nodes_variant) != TYPE_ARRAY:
		return null

	var graph := MapGraphData.new()
	graph.floor_count = maxi(0, int(data.get("floor_count", 0)))

	var nodes_data: Array = nodes_variant as Array
	for entry in nodes_data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var node_dict: Dictionary = entry as Dictionary
		var node := MapNodeData.new()
		node.id = str(node_dict.get("id", ""))
		node.type = int(node_dict.get("type", int(MapNodeData.NodeType.BATTLE)))
		node.title = str(node_dict.get("title", ""))
		node.description = str(node_dict.get("description", ""))
		node.reward_gold = int(node_dict.get("reward_gold", 0))
		node.floor_index = int(node_dict.get("floor_index", 0))
		node.lane_index = int(node_dict.get("lane_index", 0))
		node.next_node_ids = variant_to_packed_string_array(node_dict.get("next_node_ids", []))
		if node.id.is_empty():
			continue
		graph.nodes.append(node)

	if graph.nodes.is_empty():
		return null
	if graph.floor_count <= 0:
		graph.floor_count = infer_floor_count(graph.nodes)
	graph.rebuild_index()
	return graph


static func infer_floor_count(nodes: Array[MapNodeData]) -> int:
	var max_floor := 0
	for node in nodes:
		if node == null:
			continue
		max_floor = maxi(max_floor, node.floor_index)
	return max_floor + 1


static func deserialize_relics(relics_variant: Variant) -> Array[RelicData]:
	var out: Array[RelicData] = []
	if typeof(relics_variant) != TYPE_ARRAY:
		return out

	var data: Array = relics_variant as Array
	var seen_ids: Dictionary = {}
	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var dict_entry: Dictionary = entry as Dictionary
		var relic_id: String = str(dict_entry.get("id", "")).strip_edges()
		if relic_id.is_empty():
			continue
		if seen_ids.has(relic_id):
			continue

		var relic := RelicData.new()
		relic.id = relic_id
		relic.title = str(dict_entry.get("title", ""))
		relic.description = str(dict_entry.get("description", ""))
		relic.on_battle_start_heal = int(dict_entry.get("on_battle_start_heal", 0))
		relic.on_card_played_gold = int(dict_entry.get("on_card_played_gold", 0))
		relic.card_play_interval = maxi(1, int(dict_entry.get("card_play_interval", 1)))
		relic.on_player_hit_block = int(dict_entry.get("on_player_hit_block", 0))
		relic.on_enemy_killed_gold = int(dict_entry.get("on_enemy_killed_gold", 0))
		relic.on_turn_start_block = int(dict_entry.get("on_turn_start_block", 0))
		relic.on_turn_end_heal = int(dict_entry.get("on_turn_end_heal", 0))
		relic.shop_discount_percent = int(dict_entry.get("shop_discount_percent", 0))
		relic.on_run_start_gold = int(dict_entry.get("on_run_start_gold", 0))
		relic.on_run_start_max_health = int(dict_entry.get("on_run_start_max_health", 0))
		relic.on_turn_start_energy = int(dict_entry.get("on_turn_start_energy", 0))
		relic.on_turn_start_damage = int(dict_entry.get("on_turn_start_damage", 0))
		relic.on_enemy_killed_strength = int(dict_entry.get("on_enemy_killed_strength", 0))
		relic.on_enemy_killed_damage = int(dict_entry.get("on_enemy_killed_damage", 0))
		relic.on_enemy_killed_draw = int(dict_entry.get("on_enemy_killed_draw", 0))
		relic.on_battle_end_heal_per_kill = int(dict_entry.get("on_battle_end_heal_per_kill", 0))
		relic.on_attack_played_strength = int(dict_entry.get("on_attack_played_strength", 0))
		relic.attack_play_strength_max = int(dict_entry.get("attack_play_strength_max", 0))
		relic.on_run_start_strength = int(dict_entry.get("on_run_start_strength", 0))
		seen_ids[relic_id] = true
		out.append(relic)
	return out


static func deserialize_potions(potions_variant: Variant) -> Array[PotionData]:
	var out: Array[PotionData] = []
	if typeof(potions_variant) != TYPE_ARRAY:
		return out

	var data: Array = potions_variant as Array
	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var dict_entry: Dictionary = entry as Dictionary
		var potion := PotionData.new()
		potion.id = str(dict_entry.get("id", ""))
		potion.title = str(dict_entry.get("title", ""))
		potion.description = str(dict_entry.get("description", ""))
		potion.effect_type = int(dict_entry.get("effect_type", int(PotionData.EffectType.HEAL)))
		potion.value = int(dict_entry.get("value", 0))
		out.append(potion)
	return out


static func variant_to_packed_string_array(values_variant: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if typeof(values_variant) != TYPE_ARRAY:
		return out

	var values: Array = values_variant as Array
	for value in values:
		out.append(str(value))
	return out
