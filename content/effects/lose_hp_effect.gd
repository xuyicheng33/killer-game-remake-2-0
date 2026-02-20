class_name LoseHpEffect
extends Effect

var amount := 0
var target_self := false


func execute(targets: Array[Node], _battle_context: RefCounted = null) -> void:
	if target_self:
		if _battle_context != null and _battle_context.has_method("get"):
			var player = _battle_context.get("player")
			if player != null and player.stats != null:
				_apply_lose_hp_to_target(player)
	else:
		for target in targets:
			if target == null or not is_instance_valid(target):
				continue
			_apply_lose_hp_to_target(target)
	SFXPlayer.play(sound)


func _apply_lose_hp_to_target(target: Node) -> void:
	var stats = target.stats if "stats" in target else null
	if stats == null:
		return
	
	var saved_block: int = stats.block
	stats.block = 0
	stats.take_damage(amount)
	stats.block = saved_block
	if stats.health > 0:
		return
	
	if target.is_in_group("player"):
		Events.player_died.emit()
		return
	
	if target.is_in_group("enemies") and target is Enemy:
		Events.enemy_died.emit(target as Enemy)
