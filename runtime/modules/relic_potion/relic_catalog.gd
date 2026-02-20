class_name RelicCatalog
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const RELIC_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/relics/examples/common_relics.json"

static var _cache: Array[RelicData] = []


static func get_all() -> Array[RelicData]:
	_load_pool()
	return _cache.duplicate(true)


static func get_obtainable() -> Array[RelicData]:
	_load_pool()
	var out: Array[RelicData] = []
	for relic in _cache:
		if relic.rarity in ["common", "uncommon", "rare"]:
			out.append(relic)
	return out


static func pick_random(stream_key: String) -> RelicData:
	_load_pool()
	var pool := get_obtainable()
	if pool.is_empty():
		return null

	var index := RUN_RNG_SCRIPT.pick_index(stream_key, pool.size())
	if index < 0:
		return null
	return pool[index]


static func pick_random_for_reward(run_state: RunState, reward_type: String) -> RelicData:
	var stream_key := "relic_reward:%s:seed_%d:floor_%d" % [
		reward_type,
		run_state.seed if run_state else 0,
		run_state.floor if run_state else 0,
	]
	return pick_random(stream_key)


static func _load_pool() -> void:
	if not _cache.is_empty():
		return
	if not ResourceLoader.exists(RELIC_SOURCE_PATH):
		push_warning("RelicCatalog: source not found at '%s'" % RELIC_SOURCE_PATH)
		return

	var file := FileAccess.open(RELIC_SOURCE_PATH, FileAccess.READ)
	if file == null:
		push_warning("RelicCatalog: failed to open source '%s'" % RELIC_SOURCE_PATH)
		return

	var parser := JSON.new()
	var parse_code := parser.parse(file.get_as_text())
	file.close()
	if parse_code != OK:
		push_warning("RelicCatalog: failed to parse source '%s'" % RELIC_SOURCE_PATH)
		return

	var root_variant: Variant = parser.data
	if typeof(root_variant) != TYPE_DICTIONARY:
		push_warning("RelicCatalog: source root must be Dictionary")
		return
	var root: Dictionary = root_variant

	var relics_variant: Variant = root.get("relics", [])
	if typeof(relics_variant) != TYPE_ARRAY:
		push_warning("RelicCatalog: source field 'relics' must be Array")
		return

	_cache.clear()
	for item in (relics_variant as Array):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var relic_data := _parse_relic_from_dict(item as Dictionary)
		if relic_data == null:
			continue
		_cache.append(relic_data)


static func _parse_relic_from_dict(raw: Dictionary) -> RelicData:
	var relic := RelicData.new()
	relic.id = str(raw.get("id", ""))
	if relic.id.is_empty():
		return null
	relic.title = str(raw.get("title", relic.id))
	relic.description = str(raw.get("description", ""))
	relic.rarity = str(raw.get("rarity", "common"))

	var effects_variant: Variant = raw.get("effects", {})
	if typeof(effects_variant) == TYPE_DICTIONARY:
		var effects: Dictionary = effects_variant
		relic.on_battle_start_heal = int(effects.get("on_battle_start_heal", 0))
		relic.on_card_played_gold = int(effects.get("on_card_played_gold", 0))
		relic.card_play_interval = maxi(1, int(effects.get("card_play_interval", relic.card_play_interval)))
		relic.on_player_hit_block = int(effects.get("on_player_hit_block", 0))
		relic.on_enemy_killed_gold = int(effects.get("on_enemy_killed_gold", 0))
		relic.on_turn_start_block = int(effects.get("on_turn_start_block", 0))
		relic.on_turn_end_heal = int(effects.get("on_turn_end_heal", 0))
		relic.shop_discount_percent = int(effects.get("shop_discount_percent", 0))
		relic.on_run_start_gold = int(effects.get("on_run_start_gold", 0))
		relic.on_run_start_max_health = int(effects.get("on_run_start_max_health", 0))
		relic.on_turn_start_energy = int(effects.get("on_turn_start_energy", 0))
		relic.on_turn_start_damage = int(effects.get("on_turn_start_damage", 0))
		relic.on_enemy_killed_strength = int(effects.get("on_enemy_killed_strength", 0))
		relic.on_enemy_killed_damage = int(effects.get("on_enemy_killed_damage", 0))
		relic.on_enemy_killed_draw = int(effects.get("on_enemy_killed_draw", 0))
		relic.on_battle_end_heal_per_kill = int(effects.get("on_battle_end_heal_per_kill", 0))

	return relic
