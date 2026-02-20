class_name MissingHpBlockEffect
extends Effect

var percent := 0.2
var min_block := 5


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	var block_amount := min_block
	
	if battle_context != null and battle_context.has_method("get"):
		var player = battle_context.get("player")
		if player != null and player.stats != null:
			var current_hp: int = player.stats.health
			var max_hp: int = player.stats.max_health
			var missing_hp: int = max_hp - current_hp
			var calculated_block: int = int(ceil(float(missing_hp) * percent))
			block_amount = maxi(calculated_block, min_block)
	
	var block_effect := BlockEffect.new()
	block_effect.amount = block_amount
	block_effect.sound = sound
	block_effect.execute(targets, battle_context)
