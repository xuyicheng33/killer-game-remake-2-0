class_name ReproLog
extends RefCounted

const EFFECT_LOG_SETTING_PATH := "sts/debug/repro_log_effect"
const EVENT_LOG_SETTING_PATH := "sts/debug/repro_log_event"
const EFFECT_LOG_ENV_KEY := "STS_REPRO_LOG_EFFECT"
const EVENT_LOG_ENV_KEY := "STS_REPRO_LOG_EVENT"

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


static func log_effect(
	type: String,
	effect_name: String,
	source: String,
	target: String,
	value: int,
	turn: int
) -> void:
	if not _is_log_enabled(EFFECT_LOG_SETTING_PATH, EFFECT_LOG_ENV_KEY):
		return
	var line := "[effect] type=%s name=%s src=%s tgt=%s val=%d turn=%d seed=%d floor=%d" % [
		type,
		effect_name,
		source,
		target,
		value,
		turn,
		_seed,
		_floor,
	]
	push_warning(line)


static func get_current_node_id() -> String:
	return _node


static func _emit(tag: String, enemy: String, detail: String) -> void:
	if not _is_log_enabled(EVENT_LOG_SETTING_PATH, EVENT_LOG_ENV_KEY):
		return
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


static func _is_log_enabled(setting_path: String, env_key: String) -> bool:
	if ProjectSettings.has_setting(setting_path):
		return bool(ProjectSettings.get_setting(setting_path))
	var env_value := OS.get_environment(env_key).strip_edges().to_lower()
	return env_value == "1" or env_value == "true" or env_value == "yes" or env_value == "on"
