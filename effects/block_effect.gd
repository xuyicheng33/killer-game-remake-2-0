class_name BlockEffect
extends Effect

const EFFECT_STACK_ENGINE := preload("res://modules/effect_engine/effect_stack_engine.gd")

var amount := 0


func execute(targets: Array[Node]) -> void:
	var effect_name := "Block(%d)" % amount
	EFFECT_STACK_ENGINE.get_instance().enqueue_effect(effect_name, targets, _apply_block_to_target)


func _apply_block_to_target(target: Node) -> void:
	if not (target is Enemy or target is Player):
		return

	target.stats.block += amount
	SFXPlayer.play(sound)
