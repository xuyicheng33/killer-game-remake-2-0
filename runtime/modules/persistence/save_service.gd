class_name SaveService
extends RefCounted

const MAP_GENERATOR_SCRIPT := preload("res://runtime/modules/map_event/map_generator.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

const SAVE_PATH := "user://save_slot_1.json"
const SAVE_VERSION := 3
const MIN_COMPAT_VERSION := 1  # 最低兼容版本，用于向后兼容读取


static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


static func save_run_state(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _fail("run_state 为空，无法存档。", "invalid_state")

	var payload: Dictionary = _serialize_run_state(run_state)
	var json_text: String = JSON.stringify(payload)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		var open_err: int = FileAccess.get_open_error()
		return _fail("存档写入失败：%s" % error_string(open_err), "io_open_failed")

	file.store_string(json_text)
	file.close()
	return _ok("存档成功。")


static func load_run_state(base_stats: CharacterStats) -> Dictionary:
	if base_stats == null:
		return _fail("角色模板为空，无法读档。", "invalid_character")
	if not has_save():
		return _fail("未找到本地存档。", "missing")

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		var open_err: int = FileAccess.get_open_error()
		return _fail("存档读取失败：%s" % error_string(open_err), "io_open_failed")

	var raw_text: String = file.get_as_text()
	file.close()

	var parser := JSON.new()
	var parse_err: int = parser.parse(raw_text)
	if parse_err != OK:
		return _fail("存档解析失败：%s" % parser.get_error_message(), "parse_failed")
	if typeof(parser.data) != TYPE_DICTIONARY:
		return _fail("存档格式非法：根节点不是对象。", "format_invalid")

	var payload: Dictionary = parser.data as Dictionary
	var file_version: int = int(payload.get("save_version", -1))
	if file_version < MIN_COMPAT_VERSION or file_version > SAVE_VERSION:
		return _fail(
			"存档版本不兼容：当前支持 v%d~v%d，文件 v%d。" % [MIN_COMPAT_VERSION, SAVE_VERSION, file_version],
			"version_mismatch"
		)

	var restored: RunState = _deserialize_run_state(payload, base_stats)
	if restored == null:
		return _fail("存档恢复失败：关键字段缺失或无效。", "restore_failed")

	var result: Dictionary = _ok("读档成功。")
	result["run_state"] = restored
	result["rng_state"] = payload.get("rng_state", {})
	return result


static func clear_save() -> Dictionary:
	if not has_save():
		return _ok("无存档可清理。")

	var absolute_path: String = ProjectSettings.globalize_path(SAVE_PATH)
	var err: int = DirAccess.remove_absolute(absolute_path)
	if err != OK:
		return _fail("删除存档失败：%s" % error_string(err), "delete_failed")
	return _ok("存档已删除。")


static func _serialize_run_state(run_state: RunState) -> Dictionary:
	var payload: Dictionary = {}
	payload["save_version"] = SAVE_VERSION
	payload["character_id"] = run_state.character_id
	payload["seed"] = run_state.seed
	payload["act"] = run_state.act
	payload["floor"] = run_state.floor
	payload["gold"] = run_state.gold
	payload["relic_capacity"] = run_state.relic_capacity
	payload["potion_capacity"] = run_state.potion_capacity
	payload["map_current_node_id"] = run_state.map_current_node_id
	payload["map_reachable_node_ids"] = _packed_string_array_to_array(run_state.map_reachable_node_ids)
	payload["map_visited_node_ids"] = _packed_string_array_to_array(run_state.map_visited_node_ids)
	payload["map_graph"] = _serialize_map_graph(run_state.map_graph)
	payload["player_stats"] = _serialize_player_stats(run_state.player_stats)
	payload["relics"] = _serialize_relics(run_state.relics)
	payload["potions"] = _serialize_potions(run_state.potions)
	payload["rng_state"] = RUN_RNG_SCRIPT.export_run_state()
	return payload


static func _deserialize_run_state(payload: Dictionary, base_stats: CharacterStats) -> RunState:
	var seed: int = int(payload.get("seed", 0))
	var character_id: String = str(payload.get("character_id", "warrior"))
	var restored := RunState.new()
	restored.init_with_character(base_stats, seed, character_id)

	restored.act = maxi(1, int(payload.get("act", restored.act)))
	restored.floor = maxi(0, int(payload.get("floor", restored.floor)))
	restored.gold = maxi(0, int(payload.get("gold", restored.gold)))
	restored.relic_capacity = maxi(0, int(payload.get("relic_capacity", restored.relic_capacity)))
	restored.potion_capacity = maxi(0, int(payload.get("potion_capacity", restored.potion_capacity)))

	_apply_player_stats(restored, payload.get("player_stats", {}))

	var map_graph_data: Dictionary = payload.get("map_graph", {}) as Dictionary
	var deserialized_graph: MapGraphData = _deserialize_map_graph(map_graph_data)
	if deserialized_graph != null:
		restored.map_graph = deserialized_graph
	else:
		restored.map_graph = MAP_GENERATOR_SCRIPT.create_act1_seed_graph(restored.seed)

	restored.map_current_node_id = str(payload.get("map_current_node_id", ""))
	restored.map_reachable_node_ids = _variant_to_packed_string_array(payload.get("map_reachable_node_ids", []))
	restored.map_visited_node_ids = _variant_to_packed_string_array(payload.get("map_visited_node_ids", []))
	if restored.map_reachable_node_ids.is_empty() and restored.map_current_node_id.is_empty() and restored.map_graph != null:
		restored.map_reachable_node_ids = restored.map_graph.get_start_node_ids()

	restored.relics = _deserialize_relics(payload.get("relics", []))
	restored.potions = _deserialize_potions(payload.get("potions", []))
	restored.emit_changed()
	return restored


static func _serialize_player_stats(stats: CharacterStats) -> Dictionary:
	if stats == null:
		return {}

	var deck_data: Array[Dictionary] = []
	if stats.deck != null:
		for card_variant in stats.deck.cards:
			var card := card_variant as Card
			if card == null:
				continue
			deck_data.append(_serialize_card(card))

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


static func _apply_player_stats(restored: RunState, stats_variant: Variant) -> void:
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
			var card: Card = _deserialize_card(card_data)
			if card == null:
				continue
			new_deck.add_card(card)

	if new_deck.cards.is_empty() and stats.deck != null:
		new_deck = stats.deck.duplicate(true) as CardPile

	stats.deck = new_deck
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()

	# 恢复状态层（v2 新增字段，v1 存档无此字段时使用空字典默认值）
	var statuses_variant: Variant = stats_data.get("statuses", {})
	if typeof(statuses_variant) == TYPE_DICTIONARY:
		var statuses_data: Dictionary = statuses_variant as Dictionary
		for status_id: String in statuses_data:
			var stacks: int = int(statuses_data.get(status_id, 0))
			if stacks != 0:
				stats.set_status(status_id, stacks)

	stats.stats_changed.emit()


static func _serialize_card(card: Card) -> Dictionary:
	var script_path: String = ""
	var card_script: Script = card.get_script() as Script
	if card_script != null:
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
	data["type"] = int(card.type)
	data["target"] = int(card.target)
	data["cost"] = card.cost
	data["keyword_exhaust"] = card.keyword_exhaust
	data["keyword_retain"] = card.keyword_retain
	data["keyword_void"] = card.keyword_void
	data["keyword_ethereal"] = card.keyword_ethereal
	data["keyword_x_cost"] = card.keyword_x_cost
	data["tooltip_text"] = card.tooltip_text
	data["icon_path"] = icon_path
	data["sound_path"] = sound_path
	return data


static func _deserialize_card(data: Dictionary) -> Card:
	var script_path: String = str(data.get("script_path", ""))
	var card: Card = null

	if not script_path.is_empty() and ResourceLoader.exists(script_path):
		var card_script: Script = load(script_path) as Script
		if card_script != null:
			var script_instance: Variant = card_script.new()
			card = script_instance as Card

	if card == null:
		card = Card.new()

	card.id = str(data.get("id", ""))
	card.type = int(data.get("type", int(Card.Type.ATTACK)))
	card.target = int(data.get("target", int(Card.Target.SELF)))
	card.cost = int(data.get("cost", 0))
	card.keyword_exhaust = bool(data.get("keyword_exhaust", false))
	card.keyword_retain = bool(data.get("keyword_retain", false))
	card.keyword_void = bool(data.get("keyword_void", false))
	card.keyword_ethereal = bool(data.get("keyword_ethereal", false))
	card.keyword_x_cost = bool(data.get("keyword_x_cost", false))
	card.tooltip_text = str(data.get("tooltip_text", ""))

	var icon_path: String = str(data.get("icon_path", ""))
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		var icon: Texture2D = load(icon_path) as Texture2D
		if icon != null:
			card.icon = icon

	var sound_path: String = str(data.get("sound_path", ""))
	if not sound_path.is_empty() and ResourceLoader.exists(sound_path):
		var audio: AudioStream = load(sound_path) as AudioStream
		if audio != null:
			card.sound = audio

	return card


static func _serialize_map_graph(map_graph: MapGraphData) -> Dictionary:
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
		node_data["next_node_ids"] = _packed_string_array_to_array(node.next_node_ids)
		nodes.append(node_data)

	var graph_data: Dictionary = {}
	graph_data["floor_count"] = map_graph.floor_count
	graph_data["nodes"] = nodes
	return graph_data


static func _deserialize_map_graph(data: Dictionary) -> MapGraphData:
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
		node.next_node_ids = _variant_to_packed_string_array(node_dict.get("next_node_ids", []))
		if node.id.is_empty():
			continue
		graph.nodes.append(node)

	if graph.nodes.is_empty():
		return null
	if graph.floor_count <= 0:
		graph.floor_count = _infer_floor_count(graph.nodes)
	graph.rebuild_index()
	return graph


static func _infer_floor_count(nodes: Array[MapNodeData]) -> int:
	var max_floor := 0
	for node in nodes:
		if node == null:
			continue
		max_floor = maxi(max_floor, node.floor_index)
	return max_floor + 1


static func _serialize_relics(relics: Array[RelicData]) -> Array[Dictionary]:
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
		out.append(item)
	return out


static func _deserialize_relics(relics_variant: Variant) -> Array[RelicData]:
	var out: Array[RelicData] = []
	if typeof(relics_variant) != TYPE_ARRAY:
		return out

	var data: Array = relics_variant as Array
	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var dict_entry: Dictionary = entry as Dictionary
		var relic := RelicData.new()
		relic.id = str(dict_entry.get("id", ""))
		relic.title = str(dict_entry.get("title", ""))
		relic.description = str(dict_entry.get("description", ""))
		relic.on_battle_start_heal = int(dict_entry.get("on_battle_start_heal", 0))
		relic.on_card_played_gold = int(dict_entry.get("on_card_played_gold", 0))
		relic.card_play_interval = maxi(1, int(dict_entry.get("card_play_interval", 1)))
		relic.on_player_hit_block = int(dict_entry.get("on_player_hit_block", 0))
		out.append(relic)
	return out


static func _serialize_potions(potions: Array[PotionData]) -> Array[Dictionary]:
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


static func _deserialize_potions(potions_variant: Variant) -> Array[PotionData]:
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


static func _packed_string_array_to_array(values: PackedStringArray) -> Array[String]:
	var out: Array[String] = []
	for value in values:
		out.append(value)
	return out


static func _variant_to_packed_string_array(values_variant: Variant) -> PackedStringArray:
	var out := PackedStringArray()
	if typeof(values_variant) != TYPE_ARRAY:
		return out

	var values: Array = values_variant as Array
	for value in values:
		out.append(str(value))
	return out


static func _ok(message: String) -> Dictionary:
	return {
		"ok": true,
		"code": "ok",
		"message": message,
	}


static func _fail(message: String, code: String) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
	}
