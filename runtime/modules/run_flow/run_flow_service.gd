class_name RunFlowService
extends RefCounted

const SHOP_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/shop_flow_service.gd")
const EVENT_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/event_flow_service.gd")
const REST_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/rest_flow_service.gd")
const BATTLE_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/battle_flow_service.gd")
const MAP_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/map_flow_service.gd")
const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")
const FLOW_CONTEXT_SCRIPT := preload("res://runtime/modules/run_flow/flow_context.gd")
const LIFECYCLE_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/run_lifecycle_service.gd")

var shop_flow_service: ShopFlowService
var event_flow_service: EventFlowService
var rest_flow_service: RestFlowService
var battle_flow_service: BattleFlowService
var map_flow_service: MapFlowService
var route_dispatcher: RunRouteDispatcher
var flow_context: RunFlowContext
var lifecycle_service: RunLifecycleService


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher
	flow_context = FLOW_CONTEXT_SCRIPT.new() as RunFlowContext
	lifecycle_service = LIFECYCLE_SERVICE_SCRIPT.new() as RunLifecycleService
	shop_flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService
	event_flow_service = EVENT_FLOW_SERVICE_SCRIPT.new() as EventFlowService
	rest_flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService
	battle_flow_service = BATTLE_FLOW_SERVICE_SCRIPT.new(route_dispatcher) as BattleFlowService
	map_flow_service = MAP_FLOW_SERVICE_SCRIPT.new(route_dispatcher) as MapFlowService


func reset_flow_context() -> void:
	if flow_context == null:
		return
	flow_context.reset()


func apply_map_node_context(command_result: Dictionary, fallback_node_type: MapNodeData.NodeType) -> void:
	if flow_context == null:
		return
	flow_context.apply_map_node_result(command_result, fallback_node_type)


func apply_route_context(command_result: Dictionary) -> void:
	if flow_context == null:
		return
	flow_context.apply_route_result(command_result)


func get_pending_reward_gold() -> int:
	if flow_context == null:
		return 0
	return flow_context.pending_reward_gold


func get_pending_node_type() -> MapNodeData.NodeType:
	if flow_context == null:
		return MapNodeData.NodeType.BATTLE
	return flow_context.pending_node_type


func reward_gold_for(command_result: Dictionary) -> int:
	if flow_context == null:
		return int(command_result.get("reward_gold", 0))
	return flow_context.reward_gold_for(command_result)
