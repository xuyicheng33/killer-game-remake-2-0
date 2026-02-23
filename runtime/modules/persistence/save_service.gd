class_name SaveService
extends RefCounted

const MAP_GENERATOR_SCRIPT := preload("res://runtime/modules/map_event/map_generator.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const SAVE_GATEWAY_SCRIPT := preload("res://runtime/modules/persistence/save_slot_gateway.gd")
const SERIALIZER_SCRIPT := preload("res://runtime/modules/persistence/run_state_serializer.gd")
const DESERIALIZER_SCRIPT := preload("res://runtime/modules/persistence/run_state_deserializer.gd")

const SAVE_PATH := "user://save_slot_1.json"
const SAVE_VERSION := 4
const MIN_COMPAT_VERSION := 4


static func has_save() -> bool:
	return SAVE_GATEWAY_SCRIPT.has_save(SAVE_PATH)


static func save_run_state(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _fail("run_state 为空，无法存档。", "invalid_state")

	var payload: Dictionary = _serialize_run_state(run_state)
	var result: Dictionary = SAVE_GATEWAY_SCRIPT.write_payload(SAVE_PATH, payload)
	if not bool(result.get("ok", false)):
		return _fail(str(result.get("message", "存档写入失败。")), str(result.get("code", "io_open_failed")))
	return _ok("存档成功。")


static func load_run_state(base_stats: CharacterStats = null, character_template_resolver: Callable = Callable()) -> Dictionary:
	var read_result: Dictionary = SAVE_GATEWAY_SCRIPT.read_payload(SAVE_PATH)
	if not bool(read_result.get("ok", false)):
		return _fail(
			str(read_result.get("message", "读档失败。")),
			str(read_result.get("code", "io_open_failed"))
		)

	var payload_variant: Variant = read_result.get("payload", {})
	if typeof(payload_variant) != TYPE_DICTIONARY:
		return _fail("存档格式非法：根节点不是对象。", "format_invalid")
	var payload: Dictionary = payload_variant as Dictionary

	var file_version: int = int(payload.get("save_version", -1))
	if file_version < MIN_COMPAT_VERSION or file_version > SAVE_VERSION:
		return _fail(
			"存档版本不兼容：当前支持 v%d~v%d，文件 v%d。" % [MIN_COMPAT_VERSION, SAVE_VERSION, file_version],
			"version_mismatch"
		)

	var resolved_base_stats: CharacterStats = _resolve_base_stats(payload, base_stats, character_template_resolver)
	if resolved_base_stats == null:
		return _fail("角色模板为空，无法读档。", "invalid_character")

	var restored: RunState = _deserialize_run_state(payload, resolved_base_stats)
	if restored == null:
		return _fail("存档恢复失败：关键字段缺失或无效。", "restore_failed")

	var result: Dictionary = _ok("读档成功。")
	result["run_state"] = restored
	result["rng_state"] = payload.get("rng_state", {})
	return result


static func clear_save() -> Dictionary:
	var result: Dictionary = SAVE_GATEWAY_SCRIPT.clear(SAVE_PATH)
	if not bool(result.get("ok", false)):
		return _fail(str(result.get("message", "删除存档失败。")), str(result.get("code", "delete_failed")))
	return _ok(str(result.get("message", "存档已删除。")))


static func _serialize_run_state(run_state: RunState) -> Dictionary:
	return SERIALIZER_SCRIPT.serialize_run_state(run_state, SAVE_VERSION, RUN_RNG_SCRIPT.export_run_state())


static func _deserialize_run_state(payload: Dictionary, base_stats: CharacterStats) -> RunState:
	return DESERIALIZER_SCRIPT.deserialize_run_state(payload, base_stats, MAP_GENERATOR_SCRIPT)


static func _resolve_base_stats(payload: Dictionary, fallback_stats: CharacterStats, character_template_resolver: Callable) -> CharacterStats:
	return DESERIALIZER_SCRIPT.resolve_base_stats(payload, fallback_stats, character_template_resolver)


static func _serialize_player_stats(stats: CharacterStats) -> Dictionary:
	return SERIALIZER_SCRIPT.serialize_player_stats(stats)


static func _apply_player_stats(restored: RunState, stats_variant: Variant) -> void:
	DESERIALIZER_SCRIPT.apply_player_stats(restored, stats_variant)


static func _serialize_card(card: Card) -> Dictionary:
	return SERIALIZER_SCRIPT.serialize_card(card)


static func _deserialize_card(data: Dictionary) -> Card:
	return DESERIALIZER_SCRIPT.deserialize_card(data)


static func _serialize_map_graph(map_graph: MapGraphData) -> Dictionary:
	return SERIALIZER_SCRIPT.serialize_map_graph(map_graph)


static func _deserialize_map_graph(data: Dictionary) -> MapGraphData:
	return DESERIALIZER_SCRIPT.deserialize_map_graph(data)


static func _serialize_relics(relics: Array[RelicData]) -> Array[Dictionary]:
	return SERIALIZER_SCRIPT.serialize_relics(relics)


static func _deserialize_relics(relics_variant: Variant) -> Array[RelicData]:
	return DESERIALIZER_SCRIPT.deserialize_relics(relics_variant)


static func _serialize_potions(potions: Array[PotionData]) -> Array[Dictionary]:
	return SERIALIZER_SCRIPT.serialize_potions(potions)


static func _deserialize_potions(potions_variant: Variant) -> Array[PotionData]:
	return DESERIALIZER_SCRIPT.deserialize_potions(potions_variant)


static func _packed_string_array_to_array(values: PackedStringArray) -> Array[String]:
	return SERIALIZER_SCRIPT.packed_string_array_to_array(values)


static func _variant_to_packed_string_array(values_variant: Variant) -> PackedStringArray:
	return DESERIALIZER_SCRIPT.variant_to_packed_string_array(values_variant)


static func _ok(message: String) -> Dictionary:
	return {
		"ok": true,
		"code": "ok",
		"message": message,
	}


static func _fail(message: String, code: String) -> Dictionary:
	return {
		"ok": false,
		"code": code,
		"message": message,
	}
