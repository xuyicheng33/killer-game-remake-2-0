class_name EffectStackEngine
extends RefCounted

signal debug_state_changed(queue_size: int, current_item: String)

static var _instance: EffectStackEngine

var _queue: Array[Dictionary] = []
var _is_processing := false
var _current_item := "idle"
var _next_entry_id := 1


static func get_instance() -> EffectStackEngine:
	if _instance == null:
		_instance = EffectStackEngine.new()
	return _instance


func enqueue_effect(effect_name: String, targets: Array[Node], apply_callable: Callable) -> void:
	if not apply_callable.is_valid():
		return
	if targets.is_empty():
		_print_debug("enqueue_skip_empty", effect_name)
		return

	for target in targets:
		if target == null or not is_instance_valid(target):
			_print_debug("enqueue_skip_invalid_target", effect_name)
			continue

		_queue.append(
			{
				"id": _next_entry_id,
				"effect": effect_name,
				"target": target,
				"apply": apply_callable,
			}
		)
		_next_entry_id += 1

	_print_debug("enqueue", effect_name)
	_process_queue()


func get_queue_size() -> int:
	return _queue.size()


func get_current_item() -> String:
	return _current_item


func get_debug_text() -> String:
	return "queue=%d current=%s" % [_queue.size(), _current_item]


func _process_queue() -> void:
	if _is_processing:
		return

	_is_processing = true
	while not _queue.is_empty():
		var entry: Dictionary = _queue.pop_front()
		var target_variant: Variant = entry.get("target")
		if not (target_variant is Node):
			_print_debug("process_skip_invalid_target", _entry_label(entry))
			continue

		var target: Node = target_variant
		if target == null or not is_instance_valid(target):
			_print_debug("process_skip_invalid_target", _entry_label(entry))
			continue

		_current_item = _entry_label(entry)
		_print_debug("process_start", _current_item)

		var apply_variant: Variant = entry.get("apply")
		if not (apply_variant is Callable):
			_print_debug("process_skip_invalid_apply", _current_item)
			continue

		var apply_callable: Callable = apply_variant
		if apply_callable.is_valid():
			apply_callable.call(target)

		_print_debug("process_done", _current_item)

	_current_item = "idle"
	_is_processing = false
	_emit_debug_state()
	_print_debug("process_idle", _current_item)


func _entry_label(entry: Dictionary) -> String:
	var effect_name := str(entry.get("effect", "unknown_effect"))
	var target_name := "<invalid>"
	var target_variant: Variant = entry.get("target")
	if target_variant is Node:
		var target: Node = target_variant
		if target and is_instance_valid(target):
			target_name = target.name

	return "%s#%s -> %s" % [effect_name, str(entry.get("id", "?")), target_name]


func _emit_debug_state() -> void:
	debug_state_changed.emit(_queue.size(), _current_item)


func _print_debug(event: String, detail: String) -> void:
	_emit_debug_state()
	print("[EffectStack] %s | %s | queue=%d current=%s" % [event, detail, _queue.size(), _current_item])
