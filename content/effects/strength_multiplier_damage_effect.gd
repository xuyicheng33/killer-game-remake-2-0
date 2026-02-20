class_name StrengthMultiplierDamageEffect
extends Effect

var base_amount := 0
var max_hits := 3


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	var strength_stacks := 0
	if battle_context != null and battle_context.has_method("get"):
		var buff_system = battle_context.get("buff_system")
		var player = battle_context.get("player")
		if buff_system != null and player != null:
			strength_stacks = buff_system.get_status_stack(player.stats, "strength")
	
	var hit_count: int = 1 + mini(strength_stacks, max_hits - 1)
	
	for i in range(hit_count):
		var damage_effect := DamageEffect.new()
		damage_effect.amount = base_amount
		damage_effect.sound = sound
		damage_effect.execute(targets, battle_context)
