class_name RunRng
extends RefCounted

const DEFAULT_SEED := 1
const FNV_OFFSET_BASIS := 1469598103934665603
const FNV_PRIME := 1099511628211
const INT63_MASK := 0x7FFFFFFFFFFFFFFF

static var _run_seed: int = DEFAULT_SEED
static var _initialized: bool = false
static var _streams: Dictionary = {}


static func begin_run(seed: int) -> void:
	_run_seed = seed
	_streams.clear()
	_initialized = true


static func get_run_seed() -> int:
	_ensure_initialized()
	return _run_seed


static func export_run_state() -> Dictionary:
	_ensure_initialized()

	var stream_states: Dictionary = {}
	for key_variant in _streams.keys():
		var key: String = str(key_variant)
		var rng_variant: Variant = _streams.get(key_variant)
		if not (rng_variant is RandomNumberGenerator):
			continue
		var rng: RandomNumberGenerator = rng_variant
		stream_states[key] = rng.state

	return {
		"run_seed": _run_seed,
		"streams": stream_states,
	}


static func restore_run_state(state: Dictionary) -> bool:
	if state.is_empty():
		return false

	var restored_seed: int = int(state.get("run_seed", DEFAULT_SEED))
	_run_seed = restored_seed
	_streams.clear()
	_initialized = true

	var streams_variant: Variant = state.get("streams", {})
	if typeof(streams_variant) != TYPE_DICTIONARY:
		return true

	var streams: Dictionary = streams_variant as Dictionary
	for key_variant in streams.keys():
		var key: String = str(key_variant)
		var rng := RandomNumberGenerator.new()
		rng.seed = _compose_seed(_run_seed, key)
		rng.state = int(streams.get(key_variant, rng.state))
		_streams[key] = rng

	return true


static func create_seeded_rng(seed: int, stream_key: String) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = _compose_seed(seed, stream_key)
	return rng


static func randf(stream_key: String) -> float:
	return _get_stream_rng(stream_key).randf()


static func randi_range(stream_key: String, from_value: int, to_value: int) -> int:
	return _get_stream_rng(stream_key).randi_range(from_value, to_value)


static func pick_index(stream_key: String, size: int) -> int:
	if size <= 0:
		return -1
	return _get_stream_rng(stream_key).randi_range(0, size - 1)


static func _get_stream_rng(stream_key: String) -> RandomNumberGenerator:
	_ensure_initialized()

	var key: String = stream_key if not stream_key.is_empty() else "default"
	var existing_variant: Variant = _streams.get(key)
	if existing_variant is RandomNumberGenerator:
		return existing_variant

	var rng := RandomNumberGenerator.new()
	rng.seed = _compose_seed(_run_seed, key)
	_streams[key] = rng
	return rng


static func _ensure_initialized() -> void:
	if _initialized:
		return
	begin_run(DEFAULT_SEED)


static func _compose_seed(base_seed: int, stream_key: String) -> int:
	var stream_hash: int = _fnv1a64(stream_key)
	var mixed: int = int(base_seed) * 1103515245 + stream_hash + 12345
	return mixed & INT63_MASK


static func _fnv1a64(text: String) -> int:
	var hash_value := FNV_OFFSET_BASIS
	for i: int in range(text.length()):
		hash_value = hash_value ^ text.unicode_at(i)
		hash_value = int(hash_value * FNV_PRIME) & INT63_MASK
	return hash_value
