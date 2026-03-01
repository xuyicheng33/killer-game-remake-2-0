class_name RelicTriggerDispatcher
extends RefCounted


func dispatch_trigger(
	run_state: RunState,
	trigger_type: int,
	context: Dictionary,
	resolve_runtime: Callable,
	trigger_owner: Object
) -> void:
	if run_state == null:
		return

	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		var runtime_variant: Variant = resolve_runtime.call(relic_data)
		if runtime_variant == null:
			continue
		if not runtime_variant.has_method("handle_trigger"):
			continue
		runtime_variant.call("handle_trigger", trigger_type, context, trigger_owner)
