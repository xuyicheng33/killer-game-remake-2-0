class_name DrawCardEffect
extends Effect

const EFFECT_ENQUEUE_HELPER_SCRIPT := preload("res://runtime/modules/effect_engine/effect_enqueue_helper.gd")

var amount := 0


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	if amount <= 0:
		return
	if battle_context == null:
		push_warning("DrawCardEffect: battle_context is null, cannot draw cards")
		return

	var effect_name := "Draw(%d)" % amount
	if EFFECT_ENQUEUE_HELPER_SCRIPT.try_enqueue(
		battle_context,
		effect_name,
		targets,
		_apply_draw_to_target.bind(battle_context),
		50,
		EffectStackEngine.EffectType.DRAW,
		null,
		amount
	):
		return

	_apply_draw_to_target(null, battle_context)


func _apply_draw_to_target(_target: Node, battle_context: RefCounted) -> void:
	if battle_context == null:
		return
	if not battle_context.has_method("draw_cards"):
		return

	var drawn: int = int(battle_context.draw_cards(maxi(0, amount)))
	if drawn > 0:
		SFXPlayer.play(sound)
