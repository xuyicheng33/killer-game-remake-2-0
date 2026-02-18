class_name ApplyStatusEffect
extends Effect

var status_id := "weak"
var stacks := 1


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	if stacks == 0:
		return

	if battle_context == null:
		push_warning("ApplyStatusEffect: BattleContext is null, cannot apply status")
		return

	var buff_system = battle_context.get("buff_system")
	if buff_system == null:
		push_warning("ApplyStatusEffect: buff_system is null, cannot apply status")
		return

	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		buff_system.apply_status_to_target(target, status_id, stacks)
		SFXPlayer.play(sound)
