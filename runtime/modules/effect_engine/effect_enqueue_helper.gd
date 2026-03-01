class_name EffectEnqueueHelper
extends RefCounted


static func try_enqueue(
	battle_context: RefCounted,
	effect_name: String,
	targets: Array[Node],
	apply_callable: Callable,
	priority: int = 50,
	effect_type: EffectStackEngine.EffectType = EffectStackEngine.EffectType.SPECIAL,
	source: Node = null,
	value: int = 0
) -> bool:
	if battle_context == null:
		return false

	var effect_stack_variant: Variant = _resolve_effect_stack(battle_context)
	if not (effect_stack_variant is EffectStackEngine):
		return false
	var effect_stack: EffectStackEngine = effect_stack_variant as EffectStackEngine

	effect_stack.enqueue_effect(
		effect_name,
		targets,
		apply_callable,
		priority,
		effect_type,
		source,
		value
	)
	return true


static func _resolve_effect_stack(battle_context: RefCounted) -> Variant:
	if battle_context.has_method("get_effect_stack"):
		var method_stack: Variant = battle_context.call("get_effect_stack")
		if method_stack != null:
			return method_stack

	if battle_context.has_method("get"):
		var property_stack: Variant = battle_context.get("effect_stack")
		if property_stack != null:
			return property_stack

	return null
