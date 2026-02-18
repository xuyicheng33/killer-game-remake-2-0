class_name ReproLog
extends RefCounted

static var _seed: int = 0
static var _floor: int = 0
static var _node: String = ""
static var _session: int = 0


static func begin_run(seed: int) -> void:
	_seed = seed
	_floor = 0
	_node = ""
	_session += 1
	_emit("run_start", "-", "session=%d" % _session)


static func set_progress(floor: int, node_id: String) -> void:
	_floor = maxi(0, floor)
	_node = node_id
	_emit("progress", "-", "")


static func log_enemy(enemy: String, detail: String) -> void:
	var enemy_name := enemy if not enemy.is_empty() else "-"
	_emit("enemy", enemy_name, detail)


static func log_event(tag: String, detail: String) -> void:
	var normalized_tag := tag if not tag.is_empty() else "event"
	_emit(normalized_tag, "-", detail)


static func get_current_node_id() -> String:
	return _node


static func _emit(tag: String, enemy: String, detail: String) -> void:
	var node_value := _node if not _node.is_empty() else "-"
	var line := "[repro] tag=%s seed=%d floor=%d node=%s enemy=%s" % [
		tag,
		_seed,
		_floor,
		node_value,
		enemy,
	]
	if detail.length() > 0:
		line += " %s" % detail
	push_warning(line)
