class_name AppFlowOrchestrator
extends RefCounted

const CHARACTER_REGISTRY_SCRIPT := preload("res://runtime/modules/run_meta/character_registry.gd")

var _run_flow_service
var _relic_potion_system


func _init(run_flow_service, relic_potion_system) -> void:
	_run_flow_service = run_flow_service
	_relic_potion_system = relic_potion_system


func start_new_run(character_id: String = "") -> Dictionary:
	if _run_flow_service == null:
		return {"ok": false, "message": "run_flow_service 未初始化。"}

	var selected_character_id := character_id
	if selected_character_id.is_empty():
		selected_character_id = CHARACTER_REGISTRY_SCRIPT.get_selected_character_id()

	var hero_template = CHARACTER_REGISTRY_SCRIPT.get_character_template(selected_character_id)
	if hero_template == null:
		return {"ok": false, "message": "无法加载角色模板: %s" % selected_character_id}

	var result: Dictionary = _run_flow_service.lifecycle_service.start_new_run(hero_template, selected_character_id)
	if not bool(result.get("ok", false)):
		return {"ok": false, "message": "新局初始化失败。"}

	var run_state = _extract_run_state(result)
	if run_state == null:
		return {"ok": false, "message": "新局初始化失败：返回结果中缺少有效的 RunState。"}

	_run_flow_service.reset_flow_context()
	_relic_potion_system.bind_run_state(run_state)
	_run_flow_service.lifecycle_service.update_repro_progress(run_state)

	return {
		"ok": true,
		"run_state": run_state,
		"next_route": RunRouteDispatcher.ROUTE_MAP,
	}


func continue_saved_run() -> Dictionary:
	if _run_flow_service == null:
		return {"ok": false, "message": "run_flow_service 未初始化。"}

	var result: Dictionary = _run_flow_service.lifecycle_service.try_load_saved_run()
	if not bool(result.get("ok", false)):
		return {
			"ok": false,
			"message": str(result.get("message", "读档失败。")),
		}

	var run_state = _extract_run_state(result)
	if run_state == null:
		return {
			"ok": false,
			"message": "读档失败：返回结果中缺少有效的 RunState。",
		}

	_run_flow_service.reset_flow_context()
	_relic_potion_system.bind_run_state(run_state)

	return {
		"ok": true,
		"run_state": run_state,
		"next_route": RunRouteDispatcher.ROUTE_MAP,
	}


func enter_map_node(run_state, node) -> Dictionary:
	var command_result: Dictionary = _run_flow_service.map_flow_service.enter_map_node(run_state, node)
	if not bool(command_result.get("accepted", false)):
		return command_result

	_run_flow_service.apply_map_node_context(command_result, node.type)
	_run_flow_service.lifecycle_service.log_node_enter(
		str(command_result.get("node_id", node.id)),
		int(_run_flow_service.get_pending_node_type())
	)
	return command_result


func resolve_battle_completion(run_state, battle_result: int) -> Dictionary:
	var is_win: bool = battle_result == BattleOverPanel.Type.WIN
	var pending_node_type: int = int(_run_flow_service.get_pending_node_type())
	var is_boss: bool = pending_node_type == int(MapNodeData.NodeType.BOSS)
	if is_win and is_boss:
		_relic_potion_system.on_boss_killed()
	_relic_potion_system.end_battle()

	return _run_flow_service.battle_flow_service.resolve_battle_completion(
		run_state,
		is_win,
		_run_flow_service.get_pending_reward_gold(),
		is_boss
	)


func apply_battle_reward(run_state, bundle, chosen_card) -> Dictionary:
	return _run_flow_service.battle_flow_service.apply_battle_reward(run_state, bundle, chosen_card)


func resolve_non_battle_completion(run_state) -> Dictionary:
	return _run_flow_service.map_flow_service.resolve_non_battle_completion(
		run_state,
		_run_flow_service.get_pending_node_type()
	)


func dispatch_next_route(command_result: Dictionary) -> String:
	_run_flow_service.apply_route_context(command_result)
	return str(command_result.get("next_route", RunRouteDispatcher.ROUTE_MAP))


func reward_gold_for(command_result: Dictionary) -> int:
	return _run_flow_service.reward_gold_for(command_result)


func pending_node_type() -> int:
	return _run_flow_service.get_pending_node_type()


func push_external_log(text: String) -> void:
	if text.is_empty():
		return
	_relic_potion_system.push_external_log(text)


func on_shop_enter() -> void:
	_relic_potion_system.on_shop_enter()


func save_checkpoint(run_state, tag: String) -> Dictionary:
	return _run_flow_service.lifecycle_service.save_checkpoint(run_state, tag)


func _extract_run_state(result: Dictionary):
	var run_state_variant: Variant = result.get("run_state")
	if run_state_variant != null:
		return run_state_variant
	return null
