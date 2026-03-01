class_name PotionUseService
extends RefCounted

const LOG_TEMPLATES := preload("res://runtime/global/log_templates.gd")


func use_potion(
	index: int,
	run_state: RunState,
	battle_active: bool,
	effect_stack: EffectStackEngine,
	resolve_player: Callable,
	resolve_enemies: Callable,
	apply_potion_effect: Callable,
	consume_potion: Callable,
	log_emit: Callable
) -> void:
	if run_state == null:
		return
	if not battle_active:
		_emit_log(log_emit, LOG_TEMPLATES.format("potion_battle_only"))
		return
	if index < 0 or index >= run_state.potions.size():
		return

	var potion: PotionData = run_state.potions[index]
	if potion == null:
		return

	if effect_stack == null:
		push_warning("[PotionUseService] effect_stack 未注入，药水效果无法派发")
		return

	if potion.effect_type == PotionData.EffectType.DAMAGE_ALL_ENEMIES:
		_use_damage_potion(index, potion, effect_stack, resolve_enemies, consume_potion, log_emit)
		return

	var player := _resolve_player(resolve_player)
	if player == null:
		push_warning("[PotionUseService] 未找到 player，药水效果无法派发")
		return

	effect_stack.enqueue_effect(
		"potion_%s" % potion.id,
		[player],
		func(_target: Node) -> void:
			apply_potion_effect.call(index, potion),
		50,
		_potion_effect_type(potion),
		null,
		potion.value
	)


func _use_damage_potion(
	index: int,
	potion: PotionData,
	effect_stack: EffectStackEngine,
	resolve_enemies: Callable,
	consume_potion: Callable,
	log_emit: Callable
) -> void:
	var enemies := _resolve_enemies(resolve_enemies)
	if enemies.is_empty():
		_emit_log(log_emit, LOG_TEMPLATES.potion(potion.title, "potion_no_target", 0))
		return

	var damage := maxi(0, potion.value)
	effect_stack.enqueue_effect(
		"potion_%s" % potion.id,
		enemies,
		_apply_potion_damage_to_enemy.bind(damage),
		50,
		EffectStackEngine.EffectType.DAMAGE,
		null,
		damage
	)

	if consume_potion.is_valid():
		consume_potion.call(index, potion)
	_emit_log(log_emit, LOG_TEMPLATES.potion(potion.title, "potion_damage_all", damage))


func _apply_potion_damage_to_enemy(target: Node, damage: int) -> void:
	if target == null or not is_instance_valid(target):
		return
	if damage <= 0:
		return
	if target.has_method("take_damage"):
		target.call("take_damage", damage)


func _resolve_player(resolve_player: Callable) -> Node:
	if not resolve_player.is_valid():
		return null
	var player_variant: Variant = resolve_player.call()
	if player_variant is Node and is_instance_valid(player_variant):
		return player_variant as Node
	return null


func _resolve_enemies(resolve_enemies: Callable) -> Array[Node]:
	var typed_enemies: Array[Node] = []
	if not resolve_enemies.is_valid():
		return typed_enemies

	var enemies_variant: Variant = resolve_enemies.call()
	if not (enemies_variant is Array):
		return typed_enemies

	for enemy in enemies_variant:
		if enemy is Node and is_instance_valid(enemy):
			typed_enemies.append(enemy)
	return typed_enemies


func _emit_log(log_emit: Callable, message: String) -> void:
	if message.is_empty():
		return
	if log_emit.is_valid():
		log_emit.call(message)


func _potion_effect_type(potion: PotionData) -> EffectStackEngine.EffectType:
	match potion.effect_type:
		PotionData.EffectType.HEAL:
			return EffectStackEngine.EffectType.HEAL
		PotionData.EffectType.BLOCK:
			return EffectStackEngine.EffectType.BLOCK
		PotionData.EffectType.DAMAGE_ALL_ENEMIES:
			return EffectStackEngine.EffectType.DAMAGE
		_:
			return EffectStackEngine.EffectType.SPECIAL
