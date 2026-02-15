class_name DamageEffect
extends Effect

const EFFECT_STACK_ENGINE := preload("res://modules/effect_engine/effect_stack_engine.gd")
const BUFF_SYSTEM := preload("res://modules/buff_system/buff_system.gd")

var amount := 0


func execute(targets: Array[Node]) -> void:
	var effect_name := "Damage(%d)" % amount
	EFFECT_STACK_ENGINE.get_instance().enqueue_effect(effect_name, targets, _apply_damage_to_target)


func _apply_damage_to_target(target: Node) -> void:
	if not (target is Enemy or target is Player):
		return

	var buff_system := BUFF_SYSTEM.get_instance()
	var source := buff_system.resolve_damage_source(target)
	var final_damage := buff_system.get_modified_damage(amount, source, target)

	target.take_damage(final_damage)
	buff_system.on_entity_hit(target, source, final_damage)
	SFXPlayer.play(sound)
