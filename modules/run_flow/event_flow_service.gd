class_name EventFlowService
extends RefCounted

const EVENT_SERVICE_SCRIPT := preload("res://modules/map_event/event_service.gd")


func pick_event_template(run_state: RunState) -> Dictionary:
	return EVENT_SERVICE_SCRIPT.pick_event_template(run_state)


func execute_option(run_state: RunState, option: Dictionary) -> String:
	return EVENT_SERVICE_SCRIPT.apply_option(run_state, option)


func execute_continue(run_state: RunState) -> void:
	if run_state == null:
		return
	run_state.next_floor()
