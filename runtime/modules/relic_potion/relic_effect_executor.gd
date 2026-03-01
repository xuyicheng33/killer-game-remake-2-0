class_name RelicEffectExecutor
extends RefCounted

var run_state: RunState = null
var effect_stack: EffectStackEngine = null
var battle_active := false

var _player_resolver: Callable = Callable()
var _draw_cards_callable: Callable = Callable()


func bind_run_state(value: RunState) -> void:
	run_state = value


func bind_battle_session(stack: EffectStackEngine, is_battle_active: bool) -> void:
	effect_stack = stack
	battle_active = is_battle_active


func bind_resolvers(player_resolver: Callable, draw_cards_callable: Callable) -> void:
	_player_resolver = player_resolver
	_draw_cards_callable = draw_cards_callable


func dispatch_effect(effect_type: String, value: int) -> void:
	if run_state == null:
		return

	if effect_type == "add_gold" or effect_type == "increase_max_health":
		_apply_relic_effect(effect_type, value)
		return

	var player := _resolve_player()
	if effect_type == "add_strength" and (effect_stack == null or player == null):
		_apply_relic_effect(effect_type, value)
		return

	if effect_stack == null:
		push_warning("[RelicEffectExecutor] effect_stack 未注入，遗物效果无法派发: %s" % effect_type)
		return

	if player == null:
		if effect_type == "add_block":
			_apply_relic_effect(effect_type, value)
			return
		push_warning("[RelicEffectExecutor] 未找到 player，遗物效果无法派发: %s" % effect_type)
		return

	effect_stack.enqueue_effect(
		"relic_%s" % effect_type,
		[player],
		func(_target: Node) -> void:
			_apply_relic_effect(effect_type, value),
		50,
		EffectStackEngine.EffectType.SPECIAL,
		null,
		value
	)


func apply_effect(effect_type: String, value: int) -> void:
	_apply_relic_effect(effect_type, value)


func _apply_relic_effect(effect_type: String, value: int) -> void:
	if run_state == null:
		return

	match effect_type:
		"heal":
			run_state.heal_player(value)
		"add_gold":
			run_state.add_gold(value)
		"add_block":
			if run_state.player_stats != null:
				var block_gain := maxi(0, value)
				run_state.player_stats.block += block_gain
				if block_gain > 0:
					Events.player_block_applied.emit(block_gain, "relic")
				run_state.emit_changed()
		"increase_max_health":
			run_state.increase_max_health(value)
		"add_energy":
			if run_state.player_stats != null:
				var char_stats: CharacterStats = run_state.player_stats
				char_stats.mana = mini(char_stats.mana + value, char_stats.max_mana)
				run_state.emit_changed()
		"take_damage":
			_apply_relic_self_damage(value)
		"add_strength":
			if run_state.player_stats != null:
				run_state.player_stats.add_status("strength", value)
		"draw_cards":
			if run_state.player_stats != null and value > 0:
				var drawn := _draw_cards_in_battle_context(value)
				if drawn > 0:
					run_state.emit_changed()


func _apply_relic_self_damage(value: int) -> void:
	if run_state == null or run_state.player_stats == null:
		return

	var damage := maxi(0, value)
	if damage <= 0:
		return

	var stats: CharacterStats = run_state.player_stats
	var initial_health := stats.health
	stats.take_damage(damage)
	if battle_active and initial_health > 0 and stats.health <= 0:
		Events.player_died.emit()


func _resolve_player() -> Player:
	if not _player_resolver.is_valid():
		return null
	var player_variant: Variant = _player_resolver.call()
	if player_variant is Player and is_instance_valid(player_variant):
		return player_variant as Player
	return null


func _draw_cards_in_battle_context(amount: int) -> int:
	if amount <= 0:
		return 0
	if not _draw_cards_callable.is_valid():
		push_warning("[RelicEffectExecutor] draw_cards callable 未注入，效果跳过")
		return 0
	return maxi(0, int(_draw_cards_callable.call(amount)))
