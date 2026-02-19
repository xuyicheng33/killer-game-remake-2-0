extends EnemyAction

@export var poison_stacks := 2
@export var chip_damage := 2


func perform_action() -> void:
	if not enemy or not target:
		return

	var target_array: Array[Node] = [target]
	var damage_effect := DamageEffect.new()
	damage_effect.amount = chip_damage
	damage_effect.sound = sound
	damage_effect.execute(target_array, battle_context)

	if target is Player:
		var player := target as Player
		if player.stats != null:
			player.stats.add_status("poison", maxi(1, poison_stacks))

	get_tree().create_timer(0.5, false).timeout.connect(
		func() -> void:
			Events.enemy_action_completed.emit(enemy)
	)
