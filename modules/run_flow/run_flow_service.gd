class_name RunFlowService
extends RefCounted

const SHOP_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/shop_flow_service.gd")
const EVENT_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/event_flow_service.gd")
const REST_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/rest_flow_service.gd")
const BATTLE_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/battle_flow_service.gd")
const MAP_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/map_flow_service.gd")
const ROUTE_DISPATCHER_SCRIPT := preload("res://modules/run_flow/route_dispatcher.gd")

var shop_flow_service: ShopFlowService
var event_flow_service: EventFlowService
var rest_flow_service: RestFlowService
var battle_flow_service: BattleFlowService
var map_flow_service: MapFlowService
var route_dispatcher: RunRouteDispatcher


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher
	shop_flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService
	event_flow_service = EVENT_FLOW_SERVICE_SCRIPT.new() as EventFlowService
	rest_flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService
	battle_flow_service = BATTLE_FLOW_SERVICE_SCRIPT.new(route_dispatcher) as BattleFlowService
	map_flow_service = MAP_FLOW_SERVICE_SCRIPT.new(route_dispatcher) as MapFlowService
