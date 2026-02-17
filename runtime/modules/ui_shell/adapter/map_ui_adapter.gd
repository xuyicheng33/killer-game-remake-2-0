class_name MapUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)
signal node_selected(node: MapNodeData)
signal restart_requested

const MAP_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/map_ui_view_model.gd")

var _run_state: RunState
var _map_graph: MapGraphData
var _view_model: MapUIViewModel = MAP_UI_VIEW_MODEL_SCRIPT.new() as MapUIViewModel


func set_run_state(value: RunState) -> void:
	_run_state = value
	refresh()


func set_map_graph(value: MapGraphData) -> void:
	_map_graph = value
	refresh()


func refresh() -> void:
	var projection := _view_model.project_header(_run_state)
	projection["floor_rows"] = _build_floor_rows()
	projection["has_map"] = _map_graph != null
	projection_changed.emit(projection)


func request_node_selection(node: MapNodeData) -> void:
	node_selected.emit(node)


func request_restart() -> void:
	restart_requested.emit()


func _build_floor_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []

	if _map_graph == null:
		return rows

	for floor_index in range(_map_graph.floor_count):
		var floor_label := _view_model.project_floor_label(floor_index, _map_graph.floor_count)
		var nodes := _map_graph.get_nodes_for_floor(floor_index)

		var node_projections: Array[Dictionary] = []
		for node in nodes:
			node_projections.append(_view_model.project_node_text(node, _run_state))

		rows.append({
			"floor_label": floor_label,
			"nodes": node_projections,
		})

	return rows
