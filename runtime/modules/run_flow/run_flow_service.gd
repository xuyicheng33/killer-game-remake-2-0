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

var _shop_flow_service: ShopFlowService
var _event_flow_service: EventFlowService
var _rest_flow_service: RestFlowService
var _battle_flow_service: BattleFlowService
var _map_flow_service: MapFlowService

var route_dispatcher: RunRouteDispatcher
var flow_context: RunFlowContext
var lifecycle_service: RunLifecycleService

var shop_flow_service: ShopFlowService:
	get:
		if _shop_flow_service == null:
			_shop_flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService
		return _shop_flow_service

var event_flow_service: EventFlowService:
	get:
		if _event_flow_service == null:
			_event_flow_service = EVENT_FLOW_SERVICE_SCRIPT.new() as EventFlowService
		return _event_flow_service

var rest_flow_service: RestFlowService:
	get:
		if _rest_flow_service == null:
			_rest_flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService
		return _rest_flow_service

var battle_flow_service: BattleFlowService:
	get:
		if _battle_flow_service == null:
			_battle_flow_service = BATTLE_FLOW_SERVICE_SCRIPT.new(route_dispatcher) as BattleFlowService
		return _battle_flow_service

var map_flow_service: MapFlowService:
	get:
		if _map_flow_service == null:
			_map_flow_service = MAP_FLOW_SERVICE_SCRIPT.new(route_dispatcher) as MapFlowService
		return _map_flow_service


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher
	flow_context = FLOW_CONTEXT_SCRIPT.new() as RunFlowContext
	lifecycle_service = LIFECYCLE_SERVICE_SCRIPT.new() as RunLifecycleService


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
