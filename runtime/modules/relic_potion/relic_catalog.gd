class_name RelicCatalog
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

const RELIC_POOL: Array[String] = [
	"res://content/custom_resources/relics/ember_ring.tres",
	"res://content/custom_resources/relics/burning_blood.tres",
	"res://content/custom_resources/relics/golden_idol.tres",
	"res://content/custom_resources/relics/thorns_potion.tres",
	"res://content/custom_resources/relics/dawn_bulwark.tres",
	"res://content/custom_resources/relics/bounty_emblem.tres",
	"res://content/custom_resources/relics/trailblazer_emblem.tres",
	"res://content/custom_resources/relics/merchant_seal.tres",
]

static var _cache: Array[RelicData] = []


static func _load_pool() -> void:
	if not _cache.is_empty():
		return
	
	_cache.clear()
	for path in RELIC_POOL:
		if ResourceLoader.exists(path):
			var relic_variant: Variant = load(path)
			if relic_variant is RelicData:
				_cache.append(relic_variant)


static func get_all() -> Array[RelicData]:
	_load_pool()
	return _cache.duplicate()


static func pick_random(stream_key: String) -> RelicData:
	_load_pool()
	
	if _cache.is_empty():
		return null
	
	var index := RUN_RNG_SCRIPT.pick_index(stream_key, _cache.size())
	if index < 0:
		return null
	
	return _cache[index]


static func pick_random_for_reward(run_state: RunState, reward_type: String) -> RelicData:
	var stream_key := "relic_reward:%s:seed_%d:floor_%d" % [
		reward_type,
		run_state.seed if run_state else 0,
		run_state.floor if run_state else 0,
	]
	return pick_random(stream_key)
