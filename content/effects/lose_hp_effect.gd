class_name LoseHpEffect
extends Effect

var amount := 0
var target_self := false


func execute(targets: Array[Node], _battle_context: RefCounted = null) -> void:
	if target_self:
		var player: Node = null
		if _battle_context != null:
			if _battle_context.has_method("get_player"):
				var player_variant: Variant = _battle_context.call("get_player")
				if player_variant is Node:
					player = player_variant as Node
			if player == null and _battle_context.has_method("get"):
				var fallback_variant: Variant = _battle_context.get("player")
				if fallback_variant is Node:
					player = fallback_variant as Node
		if player != null:
			_apply_lose_hp_to_target(player)
	else:
		for target in targets:
			if target == null or not is_instance_valid(target):
				continue
			_apply_lose_hp_to_target(target)
	SFXPlayer.play(sound)


func _apply_lose_hp_to_target(target: Node) -> void:
	var stats: Stats = null
	if target is Player:
		stats = (target as Player).stats
	elif target is Enemy:
		stats = (target as Enemy).stats
	elif target != null and target.has_method("get"):
		var stats_variant: Variant = target.get("stats")
		if stats_variant is Stats:
			stats = stats_variant as Stats
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
