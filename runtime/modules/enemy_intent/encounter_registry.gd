class_name EncounterRegistry
extends RefCounted

const ENEMY_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/enemy_registry.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

const ENCOUNTER_DATA_PATH := "res://runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json"

static var _encounters_cache: Array[Dictionary] = []
static var _enemies_cache: Array[Dictionary] = []


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
	
	var enemies_variant: Variant = data.get("enemies", [])
	if typeof(enemies_variant) == TYPE_ARRAY:
		_enemies_cache.clear()
		for e in enemies_variant:
			if typeof(e) == TYPE_DICTIONARY:
				_enemies_cache.append(e as Dictionary)
	
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
		var enc_tags: Variant = encounter.get("tags", [])
		var floor_range: Variant = encounter.get("floor_range", {})
		
		var min_floor := 0
		var max_floor := 999
		if typeof(floor_range) == TYPE_DICTIONARY:
			min_floor = int(floor_range.get("min", 0))
			max_floor = int(floor_range.get("max", 999))
		
		if floor < min_floor or floor > max_floor:
			continue
		
		if not tags.is_empty():
			var has_tag := false
			if typeof(enc_tags) == TYPE_ARRAY:
				for tag in tags:
					if tag in enc_tags:
						has_tag = true
						break
			if not has_tag:
				continue
		
		result.append(encounter)
	
	return result


static func pick_encounter(floor: int, tags: Array[String] = [], rng_stream_key: String = "encounter_pick") -> Dictionary:
	var candidates := get_encounters_for_floor(floor, tags)
	
	if candidates.is_empty():
		_load_encounter_data()
		if not _encounters_cache.is_empty():
			push_warning("EncounterRegistry: no encounters for floor=%d tags=%s, using fallback" % [floor, tags])
			return _encounters_cache[0]
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
			result.append(e as String)
	
	return result


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
