class_name RunFlowService
extends RefCounted

const SHOP_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/shop_flow_service.gd")
const EVENT_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/event_flow_service.gd")
const REST_FLOW_SERVICE_SCRIPT := preload("res://modules/run_flow/rest_flow_service.gd")

var shop_flow_service: ShopFlowService
var event_flow_service: EventFlowService
var rest_flow_service: RestFlowService


func _init() -> void:
	shop_flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService
	event_flow_service = EVENT_FLOW_SERVICE_SCRIPT.new() as EventFlowService
	rest_flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService
