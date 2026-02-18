class_name EventFlowService
extends RefCounted

const EVENT_SERVICE_SCRIPT := preload("res://runtime/modules/map_event/event_service.gd")
const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")

var route_dispatcher: RunRouteDispatcher


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher


func pick_event_template(run_state: RunState) -> Dictionary:
	return EVENT_SERVICE_SCRIPT.pick_event_template(run_state)


func execute_option(run_state: RunState, option: Dictionary) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_EVENT, false, "当前状态无法应用事件选项。", false)
	var result_text := EVENT_SERVICE_SCRIPT.apply_option(run_state, option)
	return _result(RunRouteDispatcher.ROUTE_EVENT, true, result_text, false)


func execute_continue(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_EVENT, false, "", false)
	run_state.next_floor()
	return _result(RunRouteDispatcher.ROUTE_MAP, true, "", true)


func _result(next_route: String, handled: bool, result_text: String, completed: bool) -> Dictionary:
	return route_dispatcher.make_result(next_route, {
		"handled": handled,
		"result_text": result_text,
		"completed": completed,
	})
