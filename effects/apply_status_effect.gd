class_name ApplyStatusEffect
extends Effect

const BUFF_SYSTEM := preload("res://modules/buff_system/buff_system.gd")

@export var status_id := BUFF_SYSTEM.STATUS_WEAK
@export var stacks := 1


func execute(targets: Array[Node]) -> void:
	if stacks == 0:
		return

	var buff_system := BUFF_SYSTEM.get_instance()
	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		buff_system.apply_status_to_target(target, status_id, stacks)
		SFXPlayer.play(sound)
