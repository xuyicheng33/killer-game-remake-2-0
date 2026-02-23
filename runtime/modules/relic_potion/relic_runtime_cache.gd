class_name RelicRuntimeCache
extends RefCounted

const RELIC_REGISTRY_SCRIPT := preload("res://runtime/modules/relic_potion/relic_registry.gd")

var _runtimes: Dictionary = {}


func rebuild(run_state: RunState) -> void:
	_runtimes.clear()
	if run_state == null:
		return
	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		if relic_data.id.is_empty():
			continue
		var runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic_data)
		if runtime != null:
			_runtimes[relic_data.id] = runtime


func resolve(relic_data: RelicData) -> Variant:
	if relic_data == null or relic_data.id.is_empty():
		return null
	if _runtimes.has(relic_data.id):
		return _runtimes[relic_data.id]
	var runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic_data)
	if runtime != null:
		_runtimes[relic_data.id] = runtime
	return runtime


func prime_relic(relic: RelicData) -> void:
	if relic == null or relic.id.is_empty():
		return
	var runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic)
	if runtime != null:
		_runtimes[relic.id] = runtime


func remove(relic_id: String) -> void:
	_runtimes.erase(relic_id)


func clear() -> void:
	_runtimes.clear()


func data() -> Dictionary:
	return _runtimes
