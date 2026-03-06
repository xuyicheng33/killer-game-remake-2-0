class_name GainEnergyEffect
extends Effect

var amount := 0


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	if amount <= 0:
		return
	if battle_context == null:
		push_warning("GainEnergyEffect: battle_context is null, cannot gain energy")
		return

	var effect_name := "GainEnergy(%d)" % amount
	if EffectEnqueueHelper.try_enqueue(
		battle_context,
		effect_name,
		targets,
		_apply_energy_to_target.bind(battle_context),
		50,
		EffectStackEngine.EffectType.SPECIAL,
		null,
		amount
	):
		return

	_apply_energy_to_target(null, battle_context)


func _apply_energy_to_target(_target: Node, battle_context: RefCounted) -> void:
	if battle_context == null:
		return
	if not battle_context.has_method("gain_mana"):
		return

	var gained: int = int(battle_context.gain_mana(maxi(0, amount)))
	if gained > 0:
		SFXPlayer.play(sound)
