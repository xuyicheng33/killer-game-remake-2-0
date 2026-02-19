class_name EncounterRegistry
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const ENEMY_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/enemy_registry.gd")

const ENCOUNTER_DATA_PATH := "res://runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json"

static var _encounters_cache: Array[Dictionary] = []


static func _load_encounter_data() -> void:
	if not _encounters_cache.is_empty():
		return
	
	if not ResourceLoader.exists(ENCOUNTER_DATA_PATH):
		push_warning("EncounterRegistry: encounter data not found at '%s'" % ENCOUNTER_DATA_PATH)
		return
	
	var file := FileAccess.open(ENCOUNTER_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("EncounterRegistry: failed to open encounter data file")
		return
	
	var json_text := file.get_as_text()
	file.close()
	
	var parser := JSON.new()
	if parser.parse(json_text) != OK:
		push_warning("EncounterRegistry: failed to parse encounter data JSON")
		return
	
	var data: Dictionary = parser.data as Dictionary
	
	var encounters_variant: Variant = data.get("encounters", [])
	if typeof(encounters_variant) == TYPE_ARRAY:
		_encounters_cache.clear()
		for e in encounters_variant:
			if typeof(e) == TYPE_DICTIONARY:
				_encounters_cache.append(e as Dictionary)


static func get_encounters_for_floor(floor: int, tags: Array[String] = []) -> Array[Dictionary]:
	_load_encounter_data()
	
	var result: Array[Dictionary] = []
	for encounter in _encounters_cache:
		var floor_range: Variant = encounter.get("floor_range", {})
		
		var min_floor := 0
		var max_floor := 999
		if typeof(floor_range) == TYPE_DICTIONARY:
			min_floor = int(floor_range.get("min", 0))
			max_floor = int(floor_range.get("max", 999))
		
		if floor < min_floor or floor > max_floor:
			continue
		
		if not _encounter_matches_tags(encounter, tags):
			continue

		if not _is_encounter_enemy_ids_valid(encounter):
			continue
		
		result.append(encounter)
	
	return result


static func pick_encounter(floor: int, tags: Array[String] = [], rng_stream_key: String = "encounter_pick") -> Dictionary:
	var candidates := get_encounters_for_floor(floor, tags)
	
	if candidates.is_empty():
		push_warning("EncounterRegistry: no encounters for floor=%d tags=%s" % [floor, tags])
		return {}
	
	if candidates.size() == 1:
		return candidates[0]
	
	var total_weight := 0
	var weights: Array[int] = []
	for encounter in candidates:
		var w := int(encounter.get("weight", 1))
		weights.append(w)
		total_weight += w
	
	if total_weight <= 0:
		return candidates[0]
	
	var roll := RUN_RNG_SCRIPT.randi_range(rng_stream_key, 1, total_weight)
	var cumulative := 0
	for i in candidates.size():
		cumulative += weights[i]
		if roll <= cumulative:
			return candidates[i]
	
	return candidates[candidates.size() - 1]


static func pick_fallback_encounter(tags: Array[String] = []) -> Dictionary:
	_load_encounter_data()
	for encounter in _encounters_cache:
		if not _encounter_matches_tags(encounter, tags):
			continue
		if not _is_encounter_enemy_ids_valid(encounter):
			continue
		return encounter
	return {}


static func get_encounter_by_id(encounter_id: String) -> Dictionary:
	_load_encounter_data()
	
	for encounter in _encounters_cache:
		if str(encounter.get("id", "")) == encounter_id:
			return encounter
	
	return {}


static func get_enemy_ids_for_encounter(encounter: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var enemies_variant: Variant = encounter.get("enemies", [])
	
	if typeof(enemies_variant) != TYPE_ARRAY:
		return result
	
	var enemies: Array = enemies_variant as Array
	for e in enemies:
		if typeof(e) == TYPE_STRING:
			var enemy_id := e as String
			if ENEMY_REGISTRY_SCRIPT.has_enemy(enemy_id):
				result.append(enemy_id)
			else:
				push_warning("EncounterRegistry: encounter contains unknown enemy '%s'" % enemy_id)
	
	return result


static func _is_encounter_enemy_ids_valid(encounter: Dictionary) -> bool:
	var enemy_ids := get_enemy_ids_for_encounter(encounter)
	if enemy_ids.is_empty():
		var encounter_id := str(encounter.get("id", "unknown_encounter"))
		push_warning("EncounterRegistry: encounter '%s' has no resolvable enemies" % encounter_id)
		return false
	return true


static func _encounter_matches_tags(encounter: Dictionary, tags: Array[String]) -> bool:
	if tags.is_empty():
		return true

	var enc_tags_variant: Variant = encounter.get("tags", [])
	if typeof(enc_tags_variant) != TYPE_ARRAY:
		return false
	var enc_tags: Array = enc_tags_variant
	for tag in tags:
		if tag in enc_tags:
			return true
	return false


static func get_node_type_tags(node_type: int) -> Array[String]:
	match node_type:
		MapNodeData.NodeType.BATTLE:
			return ["common"]
		MapNodeData.NodeType.ELITE:
			return ["elite"]
		MapNodeData.NodeType.BOSS:
			return ["boss"]
		_:
			return ["common"]
