class_name EnemyRegistry
extends RefCounted

const ENEMY_DATA_PATH := "res://runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json"

static var _enemy_defs: Dictionary = {}
static var _stats_cache: Dictionary = {}
static var _loaded := false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_enemy_defs.clear()
	_stats_cache.clear()

	if not ResourceLoader.exists(ENEMY_DATA_PATH):
		push_warning("EnemyRegistry: enemy data not found at '%s'" % ENEMY_DATA_PATH)
		return

	var file := FileAccess.open(ENEMY_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("EnemyRegistry: failed to open enemy data file")
		return
	var json_text := file.get_as_text()
	file.close()

	var parser := JSON.new()
	if parser.parse(json_text) != OK:
		push_warning("EnemyRegistry: failed to parse enemy data JSON")
		return

	var payload: Variant = parser.data
	if not (payload is Dictionary):
		push_warning("EnemyRegistry: enemy data payload must be a dictionary")
		return

	var data: Dictionary = payload
	var enemies_variant: Variant = data.get("enemies", [])
	if not (enemies_variant is Array):
		push_warning("EnemyRegistry: enemies field must be an array")
		return

	for entry_variant in enemies_variant:
		if not (entry_variant is Dictionary):
			continue
		var entry: Dictionary = entry_variant
		var enemy_id := str(entry.get("id", "")).strip_edges()
		if enemy_id.is_empty():
			continue
		_enemy_defs[enemy_id] = entry.duplicate(true)


static func get_enemy_stats(enemy_id: String) -> EnemyStats:
	_ensure_loaded()

	if not _enemy_defs.has(enemy_id):
		push_warning("EnemyRegistry: unknown enemy_id '%s'" % enemy_id)
		return null

	if _stats_cache.has(enemy_id):
		var cached_variant: Variant = _stats_cache.get(enemy_id)
		if cached_variant is EnemyStats:
			return cached_variant

	var entry_variant: Variant = _enemy_defs.get(enemy_id, {})
	if not (entry_variant is Dictionary):
		push_warning("EnemyRegistry: enemy definition for '%s' is invalid" % enemy_id)
		return null

	var entry: Dictionary = entry_variant
	var max_health := int(entry.get("max_health", 0))
	if max_health <= 0:
		push_warning("EnemyRegistry: enemy '%s' has invalid max_health=%d" % [enemy_id, max_health])
		return null

	var art_path := str(entry.get("art_path", "")).strip_edges()
	var ai_scene_path := str(entry.get("ai_scene_path", "")).strip_edges()
	if art_path.is_empty() or ai_scene_path.is_empty():
		push_warning("EnemyRegistry: enemy '%s' is missing art_path or ai_scene_path" % enemy_id)
		return null
	if not ResourceLoader.exists(art_path):
		push_warning("EnemyRegistry: enemy '%s' art not found at '%s'" % [enemy_id, art_path])
		return null
	if not ResourceLoader.exists(ai_scene_path):
		push_warning("EnemyRegistry: enemy '%s' ai scene not found at '%s'" % [enemy_id, ai_scene_path])
		return null

	var art_texture := _load_texture_with_fallback(art_path)
	var ai_variant: Variant = load(ai_scene_path)
	if art_texture == null:
		push_warning("EnemyRegistry: enemy '%s' art is not Texture2D" % enemy_id)
		return null
	if not (ai_variant is PackedScene):
		push_warning("EnemyRegistry: enemy '%s' ai is not PackedScene" % enemy_id)
		return null

	var stats := EnemyStats.new()
	stats.max_health = max_health
	stats.art = art_texture
	stats.ai = ai_variant
	_stats_cache[enemy_id] = stats
	return stats


static func get_enemy_ids() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for id_variant in _enemy_defs.keys():
		ids.append(str(id_variant))
	ids.sort()
	return ids


static func has_enemy(enemy_id: String) -> bool:
	_ensure_loaded()
	return _enemy_defs.has(enemy_id)


static func _load_texture_with_fallback(art_path: String) -> Texture2D:
	var global_path := ProjectSettings.globalize_path(art_path)
	if FileAccess.file_exists(global_path):
		var image := Image.load_from_file(global_path)
		if image != null and not image.is_empty():
			return ImageTexture.create_from_image(image)

	var texture_variant: Variant = ResourceLoader.load(art_path)
	if texture_variant is Texture2D:
		return texture_variant as Texture2D
	return null
