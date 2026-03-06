extends GutTest

const ENCOUNTER_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/encounter_registry.gd")

var _cache_backup: Array[Dictionary] = []
var _by_id_backup: Dictionary = {}


func before_each() -> void:
	_cache_backup = ENCOUNTER_REGISTRY_SCRIPT._encounters_cache.duplicate(true)
	_by_id_backup = ENCOUNTER_REGISTRY_SCRIPT._encounters_by_id.duplicate(true)


func after_each() -> void:
	ENCOUNTER_REGISTRY_SCRIPT._encounters_cache = _cache_backup
	ENCOUNTER_REGISTRY_SCRIPT._encounters_by_id = _by_id_backup


func test_elite_node_picks_elite_encounter() -> void:
	var encounter := ENCOUNTER_REGISTRY_SCRIPT.pick_encounter(10, ["elite"], "test:elite")
	assert_false(encounter.is_empty(), "精英节点应选出精英遭遇")

	var tags_variant: Variant = encounter.get("tags", [])
	assert_true(tags_variant is Array, "遭遇 tags 应为数组")
	if tags_variant is Array:
		assert_true((tags_variant as Array).has("elite"), "精英节点只应产出 elite 遭遇")


func test_no_fallback_to_common_when_elite_missing() -> void:
	ENCOUNTER_REGISTRY_SCRIPT._encounters_cache = [
		{
			"id": "common_only",
			"enemies": ["crab"],
			"weight": 1,
			"tags": ["common"],
			"floor_range": {"min": 0, "max": 20},
		}
	]

	var encounter := ENCOUNTER_REGISTRY_SCRIPT.pick_encounter(10, ["elite"], "test:no_fallback")
	assert_true(encounter.is_empty(), "当无 elite 候选时不应回退到 common")
