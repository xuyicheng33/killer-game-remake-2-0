class_name MapFlowService
extends RefCounted

const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")
const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")
const ENCOUNTER_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/encounter_registry.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")
const RUN_STATE_COMMAND_SERVICE_SCRIPT := preload("res://runtime/modules/run_meta/run_state_command_service.gd")

var route_dispatcher: RunRouteDispatcher
var _commands


func _init(dispatcher: RunRouteDispatcher = null) -> void:
	route_dispatcher = dispatcher
	if route_dispatcher == null:
		route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher
	_commands = RUN_STATE_COMMAND_SERVICE_SCRIPT.new()


func enter_map_node(run_state: RunState, node: MapNodeData) -> Dictionary:
	if run_state == null or node == null:
		return route_dispatcher.make_result(
			RunRouteDispatcher.ROUTE_MAP,
			{
				"accepted": false,
			}
		)

	var next_route := route_dispatcher.route_for_map_node_type(node.type)
	var encounter_id := ""
	if next_route == RunRouteDispatcher.ROUTE_BATTLE:
		var encounter_result := _resolve_battle_encounter(run_state, node)
		if not bool(encounter_result.get("ok", false)):
			return route_dispatcher.make_result(
				RunRouteDispatcher.ROUTE_MAP,
				{
					"accepted": false,
					"error_code": str(encounter_result.get("error_code", "encounter_missing")),
					"error_text": str(encounter_result.get("error_text", "当前节点未配置可用遭遇。")),
					"node_id": node.id,
					"node_type": node.type,
				}
			)
		encounter_id = str(encounter_result.get("encounter_id", ""))

	if not _commands.enter_map_node(run_state, node.id):
		return route_dispatcher.make_result(
			RunRouteDispatcher.ROUTE_MAP,
			{
				"accepted": false,
			}
		)

	var payload := {
		"accepted": true,
		"node_id": node.id,
		"node_type": node.type,
		"reward_gold": node.reward_gold,
	}

	if next_route == RunRouteDispatcher.ROUTE_BATTLE:
		payload["encounter_id"] = encounter_id

	if next_route == RunRouteDispatcher.ROUTE_MAP:
		_commands.next_floor(run_state)
		payload["advanced_floor"] = true

	return route_dispatcher.make_result(next_route, payload)


func resolve_non_battle_completion(run_state: RunState, node_type: MapNodeData.NodeType) -> Dictionary:
	if run_state == null:
		return route_dispatcher.make_result(RunRouteDispatcher.ROUTE_MAP)

	var bonus_log := ""
	if node_type == MapNodeData.NodeType.SHOP or node_type == MapNodeData.NodeType.EVENT:
		var bonus := REWARD_GENERATOR_SCRIPT.generate_b3_bonus(node_type, run_state)
		bonus_log = REWARD_GENERATOR_SCRIPT.apply_b3_bonus(run_state, bonus)

	return route_dispatcher.make_result(
		RunRouteDispatcher.ROUTE_MAP,
		{
			"node_type": node_type,
			"bonus_log": bonus_log,
		}
	)


func _resolve_battle_encounter(run_state: RunState, node: MapNodeData) -> Dictionary:
	var tags := ENCOUNTER_REGISTRY_SCRIPT.get_node_type_tags(node.type)
	var rng_key := "encounter:%s:%s" % [run_state.seed, node.id]
	var encounter := ENCOUNTER_REGISTRY_SCRIPT.pick_encounter(run_state.floor, tags, rng_key)
	if encounter.is_empty():
		encounter = ENCOUNTER_REGISTRY_SCRIPT.pick_fallback_encounter(tags)

	var encounter_id := str(encounter.get("id", ""))
	if encounter_id.is_empty():
		push_warning(
			"MapFlowService: no encounter available for node_id=%s node_type=%s tags=%s floor=%d" % [
				node.id,
				str(node.type),
				str(tags),
				run_state.floor,
			]
		)
		var failed_result := {
			"ok": false,
			"error_code": "encounter_missing",
			"error_text": "当前战斗节点缺少可用遭遇，请检查内容配置。",
		}
		return failed_result

	var success_result := {
		"ok": true,
		"encounter_id": encounter_id,
	}
	return success_result
