class_name DamageEffect
extends Effect

var amount := 0


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	var effect_name := "Damage(%d)" % amount
	if battle_context != null and battle_context.has_method("get"):
		var es = battle_context.get("effect_stack")
		if es != null:
			es.enqueue_effect(effect_name, targets, _apply_damage_to_target.bind(battle_context))
			return
	push_warning("DamageEffect: BattleContext is null or invalid, effect may not apply correctly")


func _apply_damage_to_target(target: Node, battle_context: RefCounted) -> void:
	if not (target is Enemy or target is Player):
		return

	if battle_context == null:
		return

	var buff_system = battle_context.get("buff_system")
	if buff_system == null:
		return
	var source: Node = buff_system.resolve_damage_source(target)
	var final_damage: int = buff_system.get_modified_damage(amount, source, target)

	target.take_damage(final_damage)
	buff_system.on_entity_hit(target, source, final_damage)
	SFXPlayer.play(sound)
