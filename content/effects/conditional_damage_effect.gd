class_name ConditionalDamageEffect
extends Effect

var base_amount := 0
var condition := "hp_below_half"
var multiplier := 2


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	var effect_name := "ConditionalDamage(%d)" % base_amount
	if battle_context != null and battle_context.has_method("get"):
		var es = battle_context.get("effect_stack")
		if es != null:
			es.enqueue_effect(effect_name, targets, _apply_conditional_damage.bind(battle_context))
			return

	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		if not target.has_method("take_damage"):
			continue
		target.call("take_damage", maxi(0, base_amount))
	SFXPlayer.play(sound)


func _apply_conditional_damage(target: Node, battle_context: RefCounted) -> void:
	if not (target is Enemy or target is Player):
		return

	if battle_context == null:
		return

	var buff_system = battle_context.get("buff_system")
	if buff_system == null:
		return

	var source: Node = buff_system.resolve_damage_source(target)
	var final_damage := base_amount

	if _check_condition(source):
		final_damage = base_amount * multiplier

	final_damage = buff_system.get_modified_damage(final_damage, source, target)
	target.take_damage(final_damage)
	buff_system.on_entity_hit(target, source, final_damage)
	SFXPlayer.play(sound)


func _check_condition(source: Node) -> bool:
	if condition == "hp_below_half":
		if source == null or not is_instance_valid(source):
			return false
		if not "stats" in source:
			return false
		var stats = source.stats
		if stats == null:
			return false
		var current_hp = stats.get("health", 0)
		var max_hp = stats.get("max_health", 1)
		return current_hp <= max_hp / 2
	return false
