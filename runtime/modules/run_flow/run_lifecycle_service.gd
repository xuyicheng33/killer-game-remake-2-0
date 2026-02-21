class_name RunLifecycleService
extends RefCounted

const SAVE_SERVICE_SCRIPT := preload("res://runtime/modules/persistence/save_service.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const REPRO_LOG_SCRIPT := preload("res://runtime/global/repro_log.gd")
const CHARACTER_REGISTRY_SCRIPT := preload("res://runtime/modules/run_meta/character_registry.gd")

var _current_floor: int = 0


func start_new_run(hero_template: CharacterStats, character_id: String = "warrior") -> Dictionary:
	var seed := _resolve_run_seed()
	return start_new_run_with_seed(hero_template, seed, character_id)


func start_new_run_with_seed(hero_template: CharacterStats, seed: int, character_id: String = "warrior") -> Dictionary:
	RUN_RNG_SCRIPT.begin_run(seed)
	REPRO_LOG_SCRIPT.begin_run(seed)

	var run_state := RunState.new()
	run_state.init_with_character(hero_template, seed, character_id)
	_current_floor = run_state.floor

	return {
		"ok": true,
		"run_state": run_state,
		"seed": seed,
	}


func try_load_saved_run(fallback_template: CharacterStats = null) -> Dictionary:
	var load_result: Dictionary = SAVE_SERVICE_SCRIPT.load_run_state(
		fallback_template,
		func(character_id: String):
			return CHARACTER_REGISTRY_SCRIPT.get_character_template(character_id)
	)
	if not bool(load_result.get("ok", false)):
		return {
			"ok": false,
			"message": str(load_result.get("message", "读档失败。")),
		}

	var loaded_run_state: RunState = null
	var run_state_variant: Variant = load_result.get("run_state")
	if run_state_variant is RunState:
		loaded_run_state = run_state_variant
	if loaded_run_state == null:
		return {
			"ok": false,
			"message": "读档失败：恢复出的 RunState 为空。",
		}

	var restored_rng := false
	var rng_state_variant: Variant = load_result.get("rng_state", {})
	if typeof(rng_state_variant) == TYPE_DICTIONARY:
		restored_rng = RUN_RNG_SCRIPT.restore_run_state(rng_state_variant as Dictionary)
	if not restored_rng:
		RUN_RNG_SCRIPT.begin_run(loaded_run_state.seed)

	REPRO_LOG_SCRIPT.begin_run(RUN_RNG_SCRIPT.get_run_seed())
	_current_floor = loaded_run_state.floor
	REPRO_LOG_SCRIPT.set_progress(loaded_run_state.floor, loaded_run_state.map_current_node_id)

	return {
		"ok": true,
		"run_state": loaded_run_state,
	}


func save_checkpoint(run_state: RunState, tag: String = "") -> Dictionary:
	if run_state == null:
		return {
			"ok": false,
			"message": "run_state 为空，无法存档。",
		}

	var save_result: Dictionary = SAVE_SERVICE_SCRIPT.save_run_state(run_state)
	if not bool(save_result.get("ok", false)):
		return {
			"ok": false,
			"message": str(save_result.get("message", "存档失败。")),
		}

	return {
		"ok": true,
		"tag": tag,
	}


func update_repro_progress(run_state: RunState) -> void:
	if run_state == null:
		return
	_current_floor = run_state.floor
	REPRO_LOG_SCRIPT.set_progress(run_state.floor, run_state.map_current_node_id)


func update_repro_node(node_id: String, event_tag: String, event_detail: String) -> void:
	var next_node := REPRO_LOG_SCRIPT.get_current_node_id() if node_id.is_empty() else node_id
	REPRO_LOG_SCRIPT.set_progress(_current_floor, next_node)
	if not event_tag.is_empty():
		REPRO_LOG_SCRIPT.log_event(event_tag, event_detail)


func log_node_enter(node_id: String, node_type: int) -> void:
	var next_node := REPRO_LOG_SCRIPT.get_current_node_id() if node_id.is_empty() else node_id
	REPRO_LOG_SCRIPT.set_progress(_current_floor, next_node)
	REPRO_LOG_SCRIPT.log_event("node_enter", "type=%d" % node_type)


func _resolve_run_seed() -> int:
	var env_seed: String = OS.get_environment("STS_RUN_SEED").strip_edges()
	if not env_seed.is_empty() and env_seed.is_valid_int():
		return int(env_seed)
	return int(Time.get_unix_time_from_system()) % 1000000007
