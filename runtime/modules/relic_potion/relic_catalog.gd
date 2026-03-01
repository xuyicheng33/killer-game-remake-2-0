class_name RelicCatalog
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const RELIC_DIR := "res://content/custom_resources/relics"

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

	var dir := DirAccess.open(RELIC_DIR)
	if dir == null:
		push_warning("RelicCatalog: 无法打开遗物目录 '%s'" % RELIC_DIR)
		return

	_cache.clear()
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if not file_name.ends_with(".tres"):
			continue
		# 跳过脚本文件
		if file_name.ends_with(".gd"):
			continue

		var path := "%s/%s" % [RELIC_DIR, file_name]
		var relic_variant: Variant = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if relic_variant is RelicData:
			_cache.append(relic_variant as RelicData)

	dir.list_dir_end()
