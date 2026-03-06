class_name PotionCatalog
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const POTION_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/potions/examples/base_potions.json"

static var _cache: Array[PotionData] = []


static func _load_pool() -> void:
	if not _cache.is_empty():
		return
	if not ResourceLoader.exists(POTION_SOURCE_PATH):
		push_warning("PotionCatalog: source not found at '%s'" % POTION_SOURCE_PATH)
		return

	var file := FileAccess.open(POTION_SOURCE_PATH, FileAccess.READ)
	if file == null:
		push_warning("PotionCatalog: failed to open source '%s'" % POTION_SOURCE_PATH)
		return

	var parser := JSON.new()
	var parse_code := parser.parse(file.get_as_text())
	file.close()
	if parse_code != OK:
		push_warning("PotionCatalog: failed to parse source '%s'" % POTION_SOURCE_PATH)
		return

	var root_variant: Variant = parser.data
	if typeof(root_variant) != TYPE_DICTIONARY:
		push_warning("PotionCatalog: source root must be Dictionary")
		return

	var root: Dictionary = root_variant
	var potions_variant: Variant = root.get("potions", [])
	if typeof(potions_variant) != TYPE_ARRAY:
		push_warning("PotionCatalog: source field 'potions' must be Array")
		return

	_cache.clear()
	for item in (potions_variant as Array):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var potion := _build_potion(item as Dictionary)
		if potion != null:
			_cache.append(potion)


static func get_all() -> Array[PotionData]:
	_load_pool()
	return _cache.duplicate()


static func pick_random(stream_key: String) -> PotionData:
	_load_pool()
	if _cache.is_empty():
		return null

	var index := RUN_RNG_SCRIPT.pick_index(stream_key, _cache.size())
	if index < 0:
		return null
	return _cache[index]


static func pick_random_for_reward(run_state: RunState, reward_type: String) -> PotionData:
	var stream_key := "potion_reward:%s:seed_%d:floor_%d" % [
		reward_type,
		run_state.run_seed if run_state else 0,
		run_state.current_floor if run_state else 0,
	]
	return pick_random(stream_key)


static func _build_potion(source: Dictionary) -> PotionData:
	var potion_id := str(source.get("id", "")).strip_edges()
	var title := str(source.get("title", "")).strip_edges()
	var effect_type := _map_effect_type(str(source.get("effect_type", "")).strip_edges())
	var value_variant: Variant = source.get("value", null)
	if potion_id.is_empty() or title.is_empty() or effect_type < 0:
		return null
	if typeof(value_variant) != TYPE_INT and typeof(value_variant) != TYPE_FLOAT:
		return null

	var potion := PotionData.new()
	potion.id = potion_id
	potion.title = title
	potion.description = str(source.get("description", ""))
	potion.effect_type = effect_type
	potion.value = maxi(0, int(round(float(value_variant))))
	return potion


static func _map_effect_type(effect_type: String) -> int:
	match effect_type:
		"heal":
			return PotionData.EffectType.HEAL
		"gold":
			return PotionData.EffectType.GOLD
		"block":
			return PotionData.EffectType.BLOCK
		"damage_all_enemies":
			return PotionData.EffectType.DAMAGE_ALL_ENEMIES
		_:
			return -1
