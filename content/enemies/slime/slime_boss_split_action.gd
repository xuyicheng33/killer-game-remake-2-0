extends EnemyAction

@export var heal_amount := 10
@export var health_ratio_threshold := 0.5

var _used_once := false


func is_performable() -> bool:
	if enemy == null or enemy.stats == null:
		return false
	if _used_once:
		return false
	if enemy.stats.max_health <= 0:
		return false

	var health_ratio := float(enemy.stats.health) / float(enemy.stats.max_health)
	var can_split := health_ratio < health_ratio_threshold
	if can_split:
		_used_once = true
	return can_split


func perform_action() -> void:
	if enemy == null or enemy.stats == null:
		return

	enemy.stats.heal(maxi(0, heal_amount))
	SFXPlayer.play(sound)
	get_tree().create_timer(0.45, false).timeout.connect(
		func() -> void:
			Events.enemy_action_completed.emit(enemy)
	)
