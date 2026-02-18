class_name EventUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)
signal event_completed

const EVENT_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/event_ui_view_model.gd")
const EVENT_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/event_flow_service.gd")

var _run_state: RunState
var _view_model: EventUIViewModel = EVENT_UI_VIEW_MODEL_SCRIPT.new() as EventUIViewModel
var _flow_service: EventFlowService
var _template: Dictionary = {}
var _result_text := ""
var _continue_visible := false


func _init() -> void:
	_flow_service = EVENT_FLOW_SERVICE_SCRIPT.new() as EventFlowService


func set_run_state(value: RunState) -> void:
	_run_state = value
	_setup_template()
	refresh()


func _setup_template() -> void:
	_template = _flow_service.pick_event_template(_run_state)
	_result_text = ""
	_continue_visible = false


func refresh() -> void:
	var projection := _view_model.project(_template, _result_text, _continue_visible)
	projection_changed.emit(projection)


func execute_option(option: Dictionary) -> void:
	if _flow_service == null:
		return

	var result := _flow_service.execute_option(_run_state, option)
	if not bool(result.get("handled", false)):
		return
	_result_text = str(result.get("result_text", ""))
	_continue_visible = true
	refresh()


func execute_continue() -> void:
	if _flow_service == null:
		return

	var result := _flow_service.execute_continue(_run_state)
	if not bool(result.get("completed", false)):
		return
	if str(result.get("next_route", "")) == RunRouteDispatcher.ROUTE_MAP:
		event_completed.emit()
