extends GutTest

const EVENT_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/events/examples/baseline_events.json"
const RELIC_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/relics/examples/common_relics.json"


func test_event_templates_loaded_from_pipeline_source() -> void:
	EventCatalog._templates_cache.clear()
	var source_events := _load_entries_from_json(EVENT_SOURCE_PATH, "events")
	var templates := EventCatalog.get_templates()

	assert_eq(templates.size(), source_events.size(), "事件模板数量应与 pipeline 源数据一致")

	var source_ids := _collect_ids_from_dict_entries(source_events)
	for template in templates:
		var event_id := str(template.get("id", ""))
		assert_true(source_ids.has(event_id), "事件应来自 pipeline 数据源: %s" % event_id)


func test_relic_pool_loaded_from_pipeline_source() -> void:
	RelicCatalog._cache.clear()
	var source_relics := _load_entries_from_json(RELIC_SOURCE_PATH, "relics")
	var relic_pool := RelicCatalog.get_all()

	assert_eq(relic_pool.size(), source_relics.size(), "遗物池数量应与 pipeline 源数据一致")

	var source_ids := _collect_ids_from_dict_entries(source_relics)
	for relic in relic_pool:
		assert_true(source_ids.has(relic.id), "遗物应来自 pipeline 数据源: %s" % relic.id)


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
