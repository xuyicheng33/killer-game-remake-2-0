class_name PotionCatalog
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

const POTION_POOL: Array[String] = [
	"res://content/custom_resources/potions/healing_potion.tres",
	"res://content/custom_resources/potions/iron_skin_potion.tres",
	"res://content/custom_resources/potions/fire_potion.tres",
]

static var _cache: Array[PotionData] = []


static func _load_pool() -> void:
	if not _cache.is_empty():
		return
	
	_cache.clear()
	for path in POTION_POOL:
		if ResourceLoader.exists(path):
			var potion: PotionData = load(path) as PotionData
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
		run_state.seed if run_state else 0,
		run_state.floor if run_state else 0,
	]
	return pick_random(stream_key)
