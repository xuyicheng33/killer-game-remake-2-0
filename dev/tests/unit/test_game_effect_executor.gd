extends GutTest

var _run_state: RunState


func before_each() -> void:
	_run_state = RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 60
	stats.max_mana = 3
	stats.mana = 3
	stats.block = 0
	stats.deck = CardPile.new()
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()
	_run_state.init_with_character(stats, 12345, "warrior")


func after_each() -> void:
	_run_state = null


func _ctx(overrides: Dictionary = {}) -> Dictionary:
	var base := {"run_state": _run_state}
	base.merge(overrides, true)
	return base


func test_heal_increases_health() -> void:
	_run_state.player_stats.health = 40
	GameEffectExecutor.execute("heal", 15, _ctx())
	assert_lte(_run_state.player_stats.health, _run_state.player_stats.max_health, "血量不应超过上限")
	assert_gt(_run_state.player_stats.health, 40, "治疗应增加血量")


func test_heal_does_not_exceed_max() -> void:
	_run_state.player_stats.health = 75
	GameEffectExecutor.execute("heal", 20, _ctx())
	assert_eq(_run_state.player_stats.health, _run_state.player_stats.max_health, "治疗不应超过最大生命")


func test_block_increases_block() -> void:
	GameEffectExecutor.execute("block", 5, _ctx())
	assert_eq(_run_state.player_stats.block, 5, "应获得 5 点格挡")


func test_add_block_alias_works() -> void:
	GameEffectExecutor.execute("add_block", 8, _ctx())
	assert_eq(_run_state.player_stats.block, 8, "add_block 别名应正常工作")


func test_add_gold_increases_gold() -> void:
	var before := _run_state.gold
	GameEffectExecutor.execute("add_gold", 50, _ctx())
	assert_eq(_run_state.gold, before + 50, "应增加 50 金币")


func test_add_energy_increases_mana() -> void:
	_run_state.player_stats.mana = 1
	GameEffectExecutor.execute("add_energy", 2, _ctx())
	assert_eq(_run_state.player_stats.mana, 3, "应增加到 3 能量")


func test_add_energy_capped_at_max() -> void:
	_run_state.player_stats.mana = 2
	GameEffectExecutor.execute("add_energy", 5, _ctx())
	assert_eq(_run_state.player_stats.mana, _run_state.player_stats.max_mana, "能量不应超过上限")


func test_apply_status_adds_to_player() -> void:
	GameEffectExecutor.execute("apply_status", 0, _ctx({"status_id": "strength", "stacks": 3}))
	assert_eq(_run_state.player_stats.get_status("strength"), 3, "应添加 3 层力量")


func test_apply_status_empty_id_is_noop() -> void:
	var snapshot_before := _run_state.player_stats.get_status_snapshot()
	GameEffectExecutor.execute("apply_status", 0, _ctx({"status_id": "", "stacks": 1}))
	var snapshot_after := _run_state.player_stats.get_status_snapshot()
	assert_eq(snapshot_after.size(), snapshot_before.size(), "空 status_id 不应添加状态")


func test_take_damage_reduces_health() -> void:
	_run_state.player_stats.health = 50
	GameEffectExecutor.execute("take_damage", 10, _ctx())
	assert_lt(_run_state.player_stats.health, 50, "自伤应降低血量")


func test_add_strength_applies_status() -> void:
	GameEffectExecutor.execute("add_strength", 2, _ctx())
	assert_eq(_run_state.player_stats.get_status("strength"), 2, "应添加 2 层力量")


func test_increase_max_health() -> void:
	var before := _run_state.player_stats.max_health
	GameEffectExecutor.execute("increase_max_health", 10, _ctx())
	assert_gt(_run_state.player_stats.max_health, before, "应增加最大生命")


func test_null_run_state_does_not_crash() -> void:
	GameEffectExecutor.execute("heal", 10, {})
	assert_true(true, "空 run_state 不应崩溃")


func test_unknown_effect_type_does_not_crash() -> void:
	GameEffectExecutor.execute("nonexistent_effect", 10, _ctx())
	assert_true(true, "未知效果类型不应崩溃")


func test_draw_with_callable() -> void:
	var draw_state := {"drawn": 0}
	var draw_fn := func(amount: int) -> void:
		draw_state["drawn"] = amount
	GameEffectExecutor.execute("draw", 3, _ctx({"draw_callable": draw_fn}))
	assert_eq(int(draw_state.get("drawn", 0)), 3, "draw_callable 应被调用并传入数量")


func test_negative_value_clamped_to_zero() -> void:
	var before_health := _run_state.player_stats.health
	GameEffectExecutor.execute("heal", -5, _ctx())
	assert_eq(_run_state.player_stats.health, before_health, "负值治疗不应改变血量")
