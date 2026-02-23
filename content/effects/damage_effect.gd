class_name DamageEffect
extends Effect

const EFFECT_ENQUEUE_HELPER_SCRIPT := preload("res://runtime/modules/effect_engine/effect_enqueue_helper.gd")

var amount := 0


func execute(targets: Array[Node], battle_context: RefCounted = null) -> void:
	var effect_name := "Damage(%d)" % amount
	if EFFECT_ENQUEUE_HELPER_SCRIPT.try_enqueue(
		battle_context,
		effect_name,
		targets,
		_apply_damage_to_target.bind(battle_context)
	):
		return

	# 兜底路径：在无 BattleContext 的场景（如敌人动作脚本）仍应造成基础伤害。
	var applied := false
	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		if not target.has_method("take_damage"):
			continue
		target.call("take_damage", maxi(0, amount))
		applied = true
	if applied:
		SFXPlayer.play(sound)


func _apply_damage_to_target(target: Node, battle_context: RefCounted) -> void:
	if not (target is Enemy or target is Player):
		return

	if battle_context == null:
		return

	var buff_system = battle_context.get("buff_system")
	if buff_system == null:
		return
	var source: Node = buff_system.resolve_damage_source(target)
	var final_damage: int = buff_system.get_modified_damage(amount, source, target)

	target.take_damage(final_damage)
	buff_system.on_entity_hit(target, source, final_damage)
	SFXPlayer.play(sound)
