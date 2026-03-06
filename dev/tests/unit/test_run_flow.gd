extends GutTest


class DamageCapture extends Node:
	var damage_received := 0

	func take_damage(amount: int) -> void:
		damage_received += amount


func _build_reachable_run_state(node_type: MapNodeData.NodeType, floor: int = 0) -> Dictionary:
	var run_state := RunState.new()
	run_state.run_seed = 12345
	run_state.current_floor = floor
	run_state.map_current_node_id = ""
	run_state.map_visited_node_ids = PackedStringArray()

	var node := MapNodeData.new()
	node.id = "test_node"
	node.type = node_type
	node.reward_gold = 18
	node.floor_index = floor
	node.next_node_ids = PackedStringArray(["next_node"])

	var graph := MapGraphData.new()
	graph.floor_count = floor + 2
	graph.nodes = [node]
	graph.rebuild_index()

	run_state.map_graph = graph
	run_state.map_reachable_node_ids = PackedStringArray([node.id])

	return {
		"run_state": run_state,
		"node": node,
	}


func test_boss_victory_routes_to_run_complete() -> void:
	var service := BattleFlowService.new()
	var run_state := RunState.new()
	run_state.current_floor = 4
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
	run_state.current_floor = 2
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


func test_map_flow_rejects_battle_node_when_encounter_missing() -> void:
	var setup := _build_reachable_run_state(MapNodeData.NodeType.ELITE, 10)
	var run_state: RunState = setup.get("run_state") as RunState
	var node: MapNodeData = setup.get("node") as MapNodeData
	var service := MapFlowService.new()

	var backup_cache: Array[Dictionary] = EncounterRegistry._encounters_cache.duplicate(true)
	EncounterRegistry._encounters_cache = [
		{
			"id": "common_only",
			"enemies": ["crab"],
			"weight": 1,
			"tags": ["common"],
			"floor_range": {"min": 0, "max": 20},
		}
	]

	var result := service.enter_map_node(run_state, node)
	EncounterRegistry._encounters_cache = backup_cache

	assert_false(bool(result.get("accepted", true)), "遭遇缺失时应拒绝进入节点")
	assert_eq(str(result.get("error_code", "")), "encounter_missing", "应返回 encounter_missing 错误码")
	assert_eq(run_state.map_current_node_id, "", "拒绝进入时不应推进当前节点")
	assert_false(run_state.map_visited_node_ids.has(node.id), "拒绝进入时不应写入 visited")


func test_map_flow_battle_route_returns_encounter_id() -> void:
	var setup := _build_reachable_run_state(MapNodeData.NodeType.BATTLE, 1)
	var run_state: RunState = setup.get("run_state") as RunState
	var node: MapNodeData = setup.get("node") as MapNodeData
	var service := MapFlowService.new()

	var result := service.enter_map_node(run_state, node)

	assert_true(bool(result.get("accepted", false)), "普通战斗节点应可进入")
	assert_eq(str(result.get("next_route", "")), RunRouteDispatcher.ROUTE_BATTLE, "战斗节点应路由到 battle")
	assert_true(result.has("encounter_id"), "战斗节点返回应包含 encounter_id")
	assert_true(str(result.get("encounter_id", "")).length() > 0, "encounter_id 不应为空")
