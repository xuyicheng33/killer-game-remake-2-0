class_name RestUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)
signal rest_completed

const REST_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/rest_ui_view_model.gd")
const REST_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/rest_flow_service.gd")

var _run_state: RunState
var _view_model: RestUIViewModel = REST_UI_VIEW_MODEL_SCRIPT.new() as RestUIViewModel
var _flow_service: RestFlowService


func _init() -> void:
	_flow_service = REST_FLOW_SERVICE_SCRIPT.new() as RestFlowService


func set_run_state(value: RunState) -> void:
	_run_state = value
	refresh()


func refresh() -> void:
	var projection := _view_model.project(_run_state)
	projection_changed.emit(projection)


func execute_rest() -> void:
	if _flow_service == null:
		return
	var result := _flow_service.execute_rest(_run_state)
	if bool(result.get("completed", true)):
		rest_completed.emit()


func execute_upgrade() -> Dictionary:
	if _flow_service == null:
		return {"completed": false, "info_text": ""}
	var result := _flow_service.execute_upgrade(_run_state)
	if bool(result.get("completed", true)):
		rest_completed.emit()
	return result
