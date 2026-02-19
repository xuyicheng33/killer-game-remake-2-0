extends GutTest


class DamageCapture extends Node:
	var damage_received := 0

	func take_damage(amount: int) -> void:
		damage_received += amount


func test_boss_victory_routes_to_run_complete() -> void:
	var service := BattleFlowService.new()
	var run_state := RunState.new()
	run_state.floor = 4
	run_state.gold = 120

	var result := service.resolve_battle_completion(run_state, true, 100, true)

	assert_eq(
		str(result.get("next_route", "")),
		RunRouteDispatcher.ROUTE_RUN_COMPLETE,
		"Boss 胜利应路由到 run_complete"
	)
	assert_true(
		result.has("run_complete_text"),
		"Boss 胜利结果应包含 run_complete_text"
	)


func test_normal_victory_routes_to_reward() -> void:
	var service := BattleFlowService.new()
	var run_state := RunState.new()

	var result := service.resolve_battle_completion(run_state, true, 80, false)

	assert_eq(
		str(result.get("next_route", "")),
		RunRouteDispatcher.ROUTE_REWARD,
		"普通战斗胜利应路由到 reward"
	)
	assert_true(result.has("reward_gold"), "胜利结果应包含 reward_gold")


func test_defeat_routes_to_game_over() -> void:
	var service := BattleFlowService.new()
	var run_state := RunState.new()
	run_state.floor = 2
	run_state.gold = 50

	var result := service.resolve_battle_completion(run_state, false, 0, false)

	assert_eq(
		str(result.get("next_route", "")),
		RunRouteDispatcher.ROUTE_GAME_OVER,
		"战败应路由到 game_over"
	)


func test_boss_defeat_routes_to_game_over_not_run_complete() -> void:
	var service := BattleFlowService.new()
	var run_state := RunState.new()

	var result := service.resolve_battle_completion(run_state, false, 0, true)

	assert_eq(
		str(result.get("next_route", "")),
		RunRouteDispatcher.ROUTE_GAME_OVER,
		"Boss 战败仍应路由到 game_over 而非 run_complete"
	)


func test_x_cost_whirlwind_scales_damage_by_x() -> void:
	var card_res := preload("res://content/characters/warrior/cards/generated/warrior_whirlwind_x.tres")
	if card_res == null:
		gut.p("跳过：warrior_whirlwind_x.tres 未找到")
		return
	var card := card_res.duplicate(true) as Card
	assert_true(card.keyword_x_cost, "旋风斩应标记 keyword_x_cost")
	assert_eq(card.last_x_value, 0, "初始 last_x_value 应为 0")
	card.sound = null

	card.last_x_value = 3
	var capture := DamageCapture.new()
	card.apply_effects([capture], null)

	assert_eq(card.last_x_value, 3, "apply_effects 后 last_x_value 应保持为 3")
	assert_eq(capture.damage_received, 6, "X=3 时旋风斩应造成 2×3=6 点伤害")
	SFXPlayer.stop()
	capture.free()
