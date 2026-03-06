extends GutTest

const APP_FLOW_ORCHESTRATOR_SCRIPT := preload("res://runtime/modules/run_flow/app_flow_orchestrator.gd")
const CHARACTER_REGISTRY_SCRIPT := preload("res://runtime/modules/run_meta/character_registry.gd")

const FIXED_SEED := 20260223
const MAX_AUTOPLAY_STEPS := 80


func test_fixed_seed_autoplay_reaches_run_complete() -> void:
	var run_flow_service := RunFlowService.new()
	var relic_potion_system := RelicPotionSystem.new()
	get_tree().root.add_child(relic_potion_system)
	var orchestrator = APP_FLOW_ORCHESTRATOR_SCRIPT.new(run_flow_service, relic_potion_system)

	var hero_template: CharacterStats = CHARACTER_REGISTRY_SCRIPT.get_character_template("warrior")
	assert_not_null(hero_template, "应能加载 warrior 角色模板")
	if hero_template == null:
		return

	var bootstrap: Dictionary = run_flow_service.lifecycle_service.start_new_run_with_seed(
		hero_template,
		FIXED_SEED,
		"warrior"
	)
	assert_true(bool(bootstrap.get("ok", false)), "固定种子新局应初始化成功")
	if not bool(bootstrap.get("ok", false)):
		return

	var run_state_variant: Variant = bootstrap.get("run_state")
	assert_true(run_state_variant is RunState, "新局结果应包含 RunState")
	if not (run_state_variant is RunState):
		return
	var run_state: RunState = run_state_variant as RunState

	run_flow_service.reset_flow_context()
	relic_potion_system.bind_run_state(run_state)

	var trace: Array[String] = []
	var terminal_route := ""

	for _step in range(MAX_AUTOPLAY_STEPS):
		var node := _pick_next_node(run_state)
		assert_not_null(node, "应有可选地图节点")
		if node == null:
			break

		var enter_result: Dictionary = orchestrator.enter_map_node(run_state, node)
		assert_true(bool(enter_result.get("accepted", false)), "节点进入应成功")
		if not bool(enter_result.get("accepted", false)):
			break

		var next_route := orchestrator.dispatch_next_route(enter_result)
		trace.append(
			"floor=%d node=%s type=%d route=%s" % [
				run_state.current_floor,
				node.id,
				int(node.type),
				next_route,
			]
		)

		match next_route:
			RunRouteDispatcher.ROUTE_BATTLE:
				var battle_result := orchestrator.resolve_battle_completion(run_state, BattleOverPanel.Type.WIN)
				next_route = orchestrator.dispatch_next_route(battle_result)
				trace.append("battle_result_route=%s" % next_route)

				if next_route == RunRouteDispatcher.ROUTE_REWARD:
					var reward_gold := orchestrator.reward_gold_for(battle_result)
					var bundle := RewardGenerator.generate_post_battle_reward(run_state, reward_gold)
					var chosen_card: Card = null
					if bundle != null and not bundle.card_choices.is_empty():
						chosen_card = bundle.card_choices[0]
					var reward_result := orchestrator.apply_battle_reward(run_state, bundle, chosen_card)
					next_route = orchestrator.dispatch_next_route(reward_result)
					trace.append("reward_result_route=%s" % next_route)

			RunRouteDispatcher.ROUTE_REST:
				run_flow_service.rest_flow_service.execute_rest(run_state)
				var rest_result := orchestrator.resolve_non_battle_completion(run_state)
				next_route = orchestrator.dispatch_next_route(rest_result)
				trace.append("rest_result_route=%s" % next_route)

			RunRouteDispatcher.ROUTE_SHOP:
				run_flow_service.shop_flow_service.execute_leave(run_state)
				var shop_result := orchestrator.resolve_non_battle_completion(run_state)
				next_route = orchestrator.dispatch_next_route(shop_result)
				trace.append("shop_result_route=%s" % next_route)

			RunRouteDispatcher.ROUTE_EVENT:
				run_flow_service.event_flow_service.execute_continue(run_state)
				var event_result := orchestrator.resolve_non_battle_completion(run_state)
				next_route = orchestrator.dispatch_next_route(event_result)
				trace.append("event_result_route=%s" % next_route)

			_:
				pass

		if next_route == RunRouteDispatcher.ROUTE_RUN_COMPLETE:
			terminal_route = next_route
			break
		if next_route == RunRouteDispatcher.ROUTE_GAME_OVER:
			terminal_route = next_route
			break

	assert_eq(terminal_route, RunRouteDispatcher.ROUTE_RUN_COMPLETE, "固定种子自动跑局应到达通关路由")
	assert_gt(trace.size(), 0, "应生成自动跑局轨迹")

	relic_potion_system.queue_free()


func _pick_next_node(run_state: RunState) -> MapNodeData:
	if run_state == null:
		return null
	for node_id in run_state.map_reachable_node_ids:
		var id := str(node_id)
		if run_state.can_select_map_node(id):
			return run_state.get_map_node(id)
	return null
