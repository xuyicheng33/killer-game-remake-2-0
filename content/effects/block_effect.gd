class_name BlockEffect
extends Effect

var amount := 0


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	var effect_name := "Block(%d)" % amount
	if EffectEnqueueHelper.try_enqueue(
		battle_context,
		effect_name,
		targets,
		_apply_block_to_target.bind(battle_context)
	):
		return
	push_warning("BlockEffect: BattleContext is null or invalid, effect may not apply correctly")


func _apply_block_to_target(target: Node, battle_context: RefCounted) -> void:
	if not "stats" in target:
		return

	if battle_context == null:
		return

	var buff_system = battle_context.get("buff_system")
	if buff_system == null:
		return
	var final_block: int = buff_system.get_modified_block(amount, target)
	target.stats.block += final_block
	if final_block > 0 and target.is_in_group("player"):
		Events.player_block_applied.emit(final_block, "effect:block")
	SFXPlayer.play(sound)
