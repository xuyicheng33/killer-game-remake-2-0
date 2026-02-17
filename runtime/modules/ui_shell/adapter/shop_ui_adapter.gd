class_name ShopUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)
signal shop_completed

const SHOP_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/shop_ui_view_model.gd")
const SHOP_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/shop_flow_service.gd")

var _run_state: RunState
var _view_model: ShopUIViewModel = SHOP_UI_VIEW_MODEL_SCRIPT.new() as ShopUIViewModel
var _flow_service: ShopFlowService
var _offers: Array[Dictionary] = []
var _status_text := ""


func _init() -> void:
	_flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService


func set_run_state(value: RunState) -> void:
	_run_state = value
	_offers = _flow_service.generate_offers(_run_state)
	refresh()


func refresh() -> void:
	var projection := _view_model.project(_run_state, _offers)
	projection["status_text"] = _status_text
	projection_changed.emit(projection)


func execute_buy_offer(index: int) -> void:
	if _flow_service == null:
		return

	var result := _flow_service.execute_buy_offer(_run_state, _offers, index)
	if not bool(result.get("handled", false)):
		return

	_status_text = str(result.get("status_text", ""))
	refresh()


func execute_remove_card(index: int) -> void:
	if _flow_service == null:
		return

	var result := _flow_service.execute_remove_card(_run_state, index)
	if not bool(result.get("handled", false)):
		return

	_status_text = str(result.get("status_text", ""))
	refresh()


func execute_leave() -> void:
	if _flow_service == null:
		_flow_service = SHOP_FLOW_SERVICE_SCRIPT.new() as ShopFlowService

	_flow_service.execute_leave(_run_state)
	shop_completed.emit()
