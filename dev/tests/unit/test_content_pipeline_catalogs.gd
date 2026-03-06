extends GutTest

const EVENT_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/events/examples/baseline_events.json"
const POTION_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/potions/examples/base_potions.json"
const RELIC_DIR := "res://content/custom_resources/relics"

var _event_cache_backup: Array[Dictionary] = []
var _relic_cache_backup: Array[RelicData] = []
var _potion_cache_backup: Array[PotionData] = []
var _encounter_cache_backup: Array[Dictionary] = []
var _encounter_by_id_backup: Dictionary = {}


func before_each() -> void:
	_event_cache_backup = EventCatalog._templates_cache.duplicate(true)
	_relic_cache_backup = RelicCatalog._cache.duplicate()
	_potion_cache_backup = PotionCatalog._cache.duplicate()
	_encounter_cache_backup = EncounterRegistry._encounters_cache.duplicate(true)
	_encounter_by_id_backup = EncounterRegistry._encounters_by_id.duplicate(true)


func after_each() -> void:
	EventCatalog._templates_cache = _event_cache_backup
	RelicCatalog._cache = _relic_cache_backup
	PotionCatalog._cache = _potion_cache_backup
	EncounterRegistry._encounters_cache = _encounter_cache_backup
	EncounterRegistry._encounters_by_id = _encounter_by_id_backup


func test_event_templates_loaded_from_pipeline_source() -> void:
	EventCatalog._templates_cache.clear()
	var source_events := _load_entries_from_json(EVENT_SOURCE_PATH, "events")
	var templates := EventCatalog.get_templates()

	assert_eq(templates.size(), source_events.size(), "事件模板数量应与 pipeline 源数据一致")

	var source_ids := _collect_ids_from_dict_entries(source_events)
	for template in templates:
		var event_id := str(template.get("id", ""))
		assert_true(source_ids.has(event_id), "事件应来自 pipeline 数据源: %s" % event_id)


func test_relic_pool_loaded_from_tres_directory() -> void:
	RelicCatalog._cache.clear()
	var tres_count := _count_tres_files(RELIC_DIR)
	var relic_pool := RelicCatalog.get_all()

	assert_eq(relic_pool.size(), tres_count, "遗物池数量应与 .tres 文件数量一致")


func test_obtainable_relics_at_least_eight() -> void:
	RelicCatalog._cache.clear()
	var obtainable := RelicCatalog.get_obtainable()
	assert_true(
		obtainable.size() >= 8,
		"可获得遗物池应有至少 8 个遗物，当前 %d 个" % obtainable.size()
	)
	for relic in obtainable:
		assert_true(
			relic.rarity in ["common", "uncommon", "rare"],
			"可获得遗物稀有度应为 common/uncommon/rare，实际: %s (%s)" % [relic.rarity, relic.id]
		)


func test_starter_and_special_not_in_obtainable_pool() -> void:
	RelicCatalog._cache.clear()
	var obtainable := RelicCatalog.get_obtainable()
	for relic in obtainable:
		assert_false(
			relic.rarity in ["starter", "boss", "special"],
			"starter/boss/special 遗物不应出现在可获得池: %s (%s)" % [relic.id, relic.rarity]
		)


func _load_entries_from_json(path: String, key: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if not ResourceLoader.exists(path):
		return out

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return out

	var parser := JSON.new()
	var parse_code := parser.parse(file.get_as_text())
	file.close()
	if parse_code != OK:
		return out

	var root_variant: Variant = parser.data
	if typeof(root_variant) != TYPE_DICTIONARY:
		return out
	var root: Dictionary = root_variant
	var entries_variant: Variant = root.get(key, [])
	if typeof(entries_variant) != TYPE_ARRAY:
		return out

	for item in (entries_variant as Array):
		if typeof(item) == TYPE_DICTIONARY:
			out.append(item as Dictionary)
	return out


func _collect_ids_from_dict_entries(entries: Array[Dictionary]) -> Dictionary:
	var ids := {}
	for entry in entries:
		ids[str(entry.get("id", ""))] = true
	return ids


func _collect_dict_entries_by_id(entries: Array[Dictionary]) -> Dictionary:
	var entries_by_id := {}
	for entry in entries:
		entries_by_id[str(entry.get("id", ""))] = entry
	return entries_by_id


func _effect_type_from_string(effect_type: String) -> int:
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


func test_potion_pool_loaded_from_pipeline_source() -> void:
	PotionCatalog._cache.clear()
	var source_potions := _load_entries_from_json(POTION_SOURCE_PATH, "potions")
	var source_by_id := _collect_dict_entries_by_id(source_potions)
	var potions := PotionCatalog.get_all()

	assert_eq(potions.size(), source_potions.size(), "药水池数量应与 pipeline 源数据一致")

	for potion in potions:
		assert_true(potion is PotionData, "药水池元素应为 PotionData")
		assert_true(source_by_id.has(potion.id), "药水应来自 pipeline 数据源: %s" % potion.id)
		var source := source_by_id.get(potion.id, {})
		assert_eq(potion.title, str(source.get("title", "")), "药水 title 应与源数据一致: %s" % potion.id)
		assert_eq(potion.value, int(source.get("value", -1)), "药水 value 应与源数据一致: %s" % potion.id)
		assert_eq(
			potion.effect_type,
			_effect_type_from_string(str(source.get("effect_type", ""))),
			"药水 effect_type 应与源数据一致: %s" % potion.id
		)


func test_potion_pool_has_at_least_three() -> void:
	PotionCatalog._cache.clear()
	var potions := PotionCatalog.get_all()
	assert_true(potions.size() >= 3,
		"药水池应有至少 3 种药水，当前 %d 种" % potions.size())


func test_encounter_registry_loads_encounters() -> void:
	EncounterRegistry._encounters_cache.clear()
	EncounterRegistry._encounters_by_id.clear()
	var encounters := EncounterRegistry.get_encounters_for_floor(0)

	assert_true(encounters.size() > 0,
		"EncounterRegistry 应能为第 0 层加载至少 1 个遭遇")


func test_encounter_registry_boss_encounters() -> void:
	EncounterRegistry._encounters_cache.clear()
	EncounterRegistry._encounters_by_id.clear()
	var boss_tags: Array[String] = ["boss"]
	var boss_encounters := EncounterRegistry.get_encounters_for_floor(13, boss_tags)

	assert_true(boss_encounters.size() > 0,
		"EncounterRegistry 应包含至少 1 个 boss 遭遇（第 13 层）")


func test_encounter_registry_enemy_ids_resolvable() -> void:
	EncounterRegistry._encounters_cache.clear()
	EncounterRegistry._encounters_by_id.clear()
	var all_encounters := EncounterRegistry.get_encounters_for_floor(0)

	for encounter in all_encounters:
		var enemy_ids := EncounterRegistry.get_enemy_ids_for_encounter(encounter)
		assert_true(enemy_ids.size() > 0,
			"遭遇 '%s' 应有至少 1 个可解析的敌人 ID" % str(encounter.get("id", "unknown")))


func test_encounter_registry_get_by_id() -> void:
	EncounterRegistry._encounters_cache.clear()
	EncounterRegistry._encounters_by_id.clear()
	var all_encounters := EncounterRegistry.get_encounters_for_floor(0)

	if all_encounters.is_empty():
		pass_test("无遭遇数据，跳过 ID 查询测试")
		return

	var first_id: String = str(all_encounters[0].get("id", ""))
	if first_id.is_empty():
		pass_test("首个遭遇无 ID，跳过查询测试")
		return

	var found := EncounterRegistry.get_encounter_by_id(first_id)
	assert_false(found.is_empty(), "应能通过 ID 查询到遭遇: %s" % first_id)


func _count_tres_files(dir_path: String) -> int:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return 0

	var count := 0
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if not file_name.ends_with(".tres"):
			continue
		count += 1
	dir.list_dir_end()
	return count
