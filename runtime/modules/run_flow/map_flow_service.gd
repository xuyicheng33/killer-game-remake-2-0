class_name MapFlowService
extends RefCounted

const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")
const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")
const ENCOUNTER_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/encounter_registry.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

var route_dispatcher: RunRouteDispatcher


func _init(dispatcher: RunRouteDispatcher = null) -> void:
	route_dispatcher = dispatcher
	if route_dispatcher == null:
		route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher


func enter_map_node(run_state: RunState, node: MapNodeData) -> Dictionary:
	if run_state == null or node == null:
		return route_dispatcher.make_result(
			RunRouteDispatcher.ROUTE_MAP,
			{
				"accepted": false,
			}
		)

	if not run_state.enter_map_node(node.id):
		return route_dispatcher.make_result(
			RunRouteDispatcher.ROUTE_MAP,
			{
				"accepted": false,
			}
		)

	var next_route := route_dispatcher.route_for_map_node_type(node.type)
	var payload := {
		"accepted": true,
		"node_id": node.id,
		"node_type": node.type,
		"reward_gold": node.reward_gold,
	}

	if next_route == RunRouteDispatcher.ROUTE_BATTLE:
		var tags := ENCOUNTER_REGISTRY_SCRIPT.get_node_type_tags(node.type)
		var rng_key := "encounter:%s:%s" % [run_state.seed, node.id]
		var encounter := ENCOUNTER_REGISTRY_SCRIPT.pick_encounter(run_state.floor, tags, rng_key)
		payload["encounter_id"] = str(encounter.get("id", ""))

	if next_route == RunRouteDispatcher.ROUTE_MAP:
		run_state.next_floor()
		payload["advanced_floor"] = true

	return route_dispatcher.make_result(next_route, payload)


func resolve_non_battle_completion(run_state: RunState, node_type: MapNodeData.NodeType) -> Dictionary:
	if run_state == null:
		return route_dispatcher.make_result(RunRouteDispatcher.ROUTE_MAP)

	var bonus_log := ""
	if node_type == MapNodeData.NodeType.SHOP or node_type == MapNodeData.NodeType.EVENT:
		var bonus := REWARD_GENERATOR_SCRIPT.generate_b3_bonus(node_type)
		bonus_log = REWARD_GENERATOR_SCRIPT.apply_b3_bonus(run_state, bonus)

	return route_dispatcher.make_result(
		RunRouteDispatcher.ROUTE_MAP,
		{
			"node_type": node_type,
			"bonus_log": bonus_log,
		}
	)
