extends EnemyAction

@export var damage := 18
@export var vulnerable_stacks := 2


func perform_action() -> void:
	if not enemy or not target:
		return

	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 40
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = damage
	damage_effect.sound = sound

	tween.tween_property(enemy, "global_position", end, 0.45)
	tween.tween_callback(damage_effect.execute.bind(target_array, battle_context))
	tween.tween_interval(0.2)
	tween.tween_callback(_apply_vulnerable_to_player.bind(target))
	tween.tween_property(enemy, "global_position", start, 0.45)

	tween.finished.connect(
		func() -> void:
			Events.enemy_action_completed.emit(enemy)
	)


func _apply_vulnerable_to_player(node: Node) -> void:
	if node is Player:
		var player := node as Player
		if player.stats != null:
			player.stats.add_status("vulnerable", maxi(1, vulnerable_stacks))
