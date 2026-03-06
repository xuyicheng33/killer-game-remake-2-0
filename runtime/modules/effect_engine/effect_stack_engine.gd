class_name EffectStackEngine
extends RefCounted

signal debug_state_changed(queue_size: int, current_item: String)

enum EffectType {
	DAMAGE,
	BLOCK,
	HEAL,
	DRAW,
	APPLY_STATUS,
	REMOVE_STATUS,
	SPECIAL,
}

const MAX_CHAIN_DEPTH := 10
const DEBUG_SETTING_PATH := "sts/debug/effect_stack_verbose"
const DEBUG_ENV_KEY := "STS_EFFECT_STACK_DEBUG"

var _queue: Array[Dictionary] = []
var _is_processing := false
var _current_item := "idle"
var _next_entry_id := 1
var _chain_depth := 0
var _current_turn := 0


func enqueue_effect(
	effect_name: String,
	targets: Array[Node],
	apply_callable: Callable,
	priority: int = 50,
	effect_type: EffectType = EffectType.SPECIAL,
	source: Node = null,
	value: int = 0,
	chain_depth: int = 0
) -> void:
	if not apply_callable.is_valid():
		return
	if targets.is_empty():
		_print_debug("enqueue_skip_empty", effect_name)
		return

	for target in targets:
		if target == null or not is_instance_valid(target):
			_print_debug("enqueue_skip_invalid_target", effect_name)
			continue

		var entry := {
			"id": _next_entry_id,
			"effect": effect_name,
			"effect_type": effect_type,
			"target": target,
			"apply": apply_callable,
			"priority": priority,
			"source": source,
			"value": value,
			"chain_depth": maxi(0, chain_depth),
		}
		_insert_sorted(entry)
		_next_entry_id += 1

	_print_debug("enqueue", effect_name)
	_try_process_queue()


func _try_process_queue() -> void:
	if _is_processing:
		return
	_process_queue()


func set_current_turn(turn: int) -> void:
	_current_turn = maxi(turn, 0)


func get_queue_size() -> int:
	return _queue.size()


func get_current_item() -> String:
	return _current_item


func get_debug_text() -> String:
	return "queue=%d current=%s chain_depth=%d" % [_queue.size(), _current_item, _chain_depth]


func _process_queue() -> void:
	if _is_processing:
		return

	_is_processing = true

	while not _queue.is_empty():
		var entry: Dictionary = _queue.pop_front()
		var entry_chain_depth := int(entry.get("chain_depth", 0))
		if entry_chain_depth > MAX_CHAIN_DEPTH:
			push_error("[EffectStack] 链式递归深度超过限制 (>%d)，中止执行" % MAX_CHAIN_DEPTH)
			continue
		_chain_depth = entry_chain_depth

		var target_variant: Variant = entry.get("target")
		if not (target_variant is Node):
			_print_debug("process_skip_invalid_target", _entry_label(entry))
			_chain_depth = 0
			continue

		var target: Node = target_variant
		if target == null or not is_instance_valid(target):
			_print_debug("process_skip_invalid_target", _entry_label(entry))
			_chain_depth = 0
			continue

		_current_item = _entry_label(entry)
		_print_debug("process_start", _current_item)

		var apply_variant: Variant = entry.get("apply")
		if not (apply_variant is Callable):
			_print_debug("process_skip_invalid_apply", _current_item)
			_chain_depth = 0
			continue

		var apply_callable: Callable = apply_variant
		if apply_callable.is_valid():
			var result = apply_callable.call(target)
			_log_effect(entry, target)
			_handle_chain_result(result, entry)

		_print_debug("process_done", _current_item)
		_chain_depth = 0

	_current_item = "idle"
	_chain_depth = 0
	_is_processing = false
	_emit_debug_state()
	_print_debug("process_idle", _current_item)


func _insert_sorted(entry: Dictionary) -> void:
	var priority: int = entry.get("priority", 50)
	var insert_idx := _queue.size()
	for i in range(_queue.size()):
		if _queue[i].get("priority", 50) < priority:
			insert_idx = i
			break
	_queue.insert(insert_idx, entry)


func _log_effect(entry: Dictionary, target: Node) -> void:
	var effect_type: int = entry.get("effect_type", EffectType.SPECIAL)
	var source: Node = entry.get("source")
	var value: int = entry.get("value", 0)
	var effect_name: String = entry.get("effect", "unknown")

	var source_name := "<none>"
	if source != null and is_instance_valid(source):
		source_name = source.name

	var target_name := "<invalid>"
	if target != null and is_instance_valid(target):
		target_name = target.name

	ReproLog.log_effect(
		_effect_type_name(effect_type),
		effect_name,
		source_name,
		target_name,
		value,
		_current_turn
	)


func _handle_chain_result(result: Variant, entry: Dictionary) -> void:
	if not (result is Dictionary):
		return

	var result_dict: Dictionary = result
	if not result_dict.has("chain_effects"):
		return

	var chain_effects_variant: Variant = result_dict.get("chain_effects")
	if not (chain_effects_variant is Array):
		return

	var chain_effects: Array = chain_effects_variant
	var parent_depth := int(entry.get("chain_depth", 0))
	for chain_effect in chain_effects:
		if not (chain_effect is Dictionary):
			continue
		_enqueue_chain_effect(chain_effect as Dictionary, parent_depth)


func _enqueue_chain_effect(chain_effect: Dictionary, parent_depth: int) -> void:
	var effect_name: String = chain_effect.get("effect", "chain_effect")
	var targets: Array = chain_effect.get("targets", [])
	var apply_callable: Callable = chain_effect.get("apply", Callable())
	var priority: int = chain_effect.get("priority", 50)
	var effect_type: int = chain_effect.get("effect_type", EffectType.SPECIAL)
	var source: Node = chain_effect.get("source")
	var value: int = chain_effect.get("value", 0)

	if not apply_callable.is_valid():
		return

	var typed_targets: Array[Node] = []
	for t in targets:
		if t is Node and is_instance_valid(t):
			typed_targets.append(t)

	if typed_targets.is_empty():
		return

	var next_depth := parent_depth + 1
	if next_depth > MAX_CHAIN_DEPTH:
		push_error("[EffectStack] 链式递归深度超过限制 (>%d)，中止执行" % MAX_CHAIN_DEPTH)
		return

	enqueue_effect(effect_name, typed_targets, apply_callable, priority, effect_type, source, value, next_depth)


func _entry_label(entry: Dictionary) -> String:
	var effect_name := str(entry.get("effect", "unknown_effect"))
	var target_name := "<invalid>"
	var target_variant: Variant = entry.get("target")
	if target_variant is Node:
		var target: Node = target_variant
		if target and is_instance_valid(target):
			target_name = target.name

	return "%s#%s -> %s" % [effect_name, str(entry.get("id", "?")), target_name]


func _effect_type_name(effect_type: int) -> String:
	match effect_type:
		EffectType.DAMAGE: return "DAMAGE"
		EffectType.BLOCK: return "BLOCK"
		EffectType.HEAL: return "HEAL"
		EffectType.DRAW: return "DRAW"
		EffectType.APPLY_STATUS: return "APPLY_STATUS"
		EffectType.REMOVE_STATUS: return "REMOVE_STATUS"
		EffectType.SPECIAL: return "SPECIAL"
		_: return "UNKNOWN"


func _emit_debug_state() -> void:
	debug_state_changed.emit(_queue.size(), _current_item)


func _print_debug(event: String, detail: String) -> void:
	_emit_debug_state()
	if not _is_debug_logging_enabled():
		return
	print("[EffectStack] %s | %s | queue=%d current=%s chain=%d" % [
		event, detail, _queue.size(), _current_item, _chain_depth
	])


func _is_debug_logging_enabled() -> bool:
	if ProjectSettings.has_setting(DEBUG_SETTING_PATH):
		return bool(ProjectSettings.get_setting(DEBUG_SETTING_PATH))
	var env_value := OS.get_environment(DEBUG_ENV_KEY).strip_edges().to_lower()
	return env_value == "1" or env_value == "true" or env_value == "yes" or env_value == "on"
