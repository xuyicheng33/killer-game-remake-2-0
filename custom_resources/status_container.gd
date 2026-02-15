class_name StatusContainer
extends Resource

var _stacks: Dictionary = {}


func get_stack(status_id: String) -> int:
	var value: Variant = _stacks.get(status_id, 0)
	if value is int:
		return maxi(value, 0)
	return 0


func set_stack(status_id: String, value: int) -> bool:
	var next_value := maxi(value, 0)
	var previous_value := get_stack(status_id)

	if next_value == 0:
		_stacks.erase(status_id)
	else:
		_stacks[status_id] = next_value

	return previous_value != next_value


func add_stack(status_id: String, delta: int) -> int:
	if delta == 0:
		return get_stack(status_id)

	set_stack(status_id, get_stack(status_id) + delta)
	return get_stack(status_id)


func clear_all() -> void:
	_stacks.clear()


func snapshot() -> Dictionary:
	return _stacks.duplicate(true)
