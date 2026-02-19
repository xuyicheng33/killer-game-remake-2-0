class_name EventCatalog
extends RefCounted

const EVENT_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/events/examples/baseline_events.json"

static var _templates_cache: Array[Dictionary] = []


static func get_templates() -> Array[Dictionary]:
	_load_templates()
	return _templates_cache.duplicate(true)


static func _load_templates() -> void:
	if not _templates_cache.is_empty():
		return
	if not ResourceLoader.exists(EVENT_SOURCE_PATH):
		push_warning("EventCatalog: source not found at '%s'" % EVENT_SOURCE_PATH)
		return

	var file := FileAccess.open(EVENT_SOURCE_PATH, FileAccess.READ)
	if file == null:
		push_warning("EventCatalog: failed to open source '%s'" % EVENT_SOURCE_PATH)
		return

	var parser := JSON.new()
	var parse_code := parser.parse(file.get_as_text())
	file.close()
	if parse_code != OK:
		push_warning("EventCatalog: failed to parse source '%s'" % EVENT_SOURCE_PATH)
		return

	var root_variant: Variant = parser.data
	if typeof(root_variant) != TYPE_DICTIONARY:
		push_warning("EventCatalog: source root must be Dictionary")
		return

	var root: Dictionary = root_variant
	var events_variant: Variant = root.get("events", [])
	if typeof(events_variant) != TYPE_ARRAY:
		push_warning("EventCatalog: source field 'events' must be Array")
		return

	_templates_cache.clear()
	for item in (events_variant as Array):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		_templates_cache.append((item as Dictionary).duplicate(true))
