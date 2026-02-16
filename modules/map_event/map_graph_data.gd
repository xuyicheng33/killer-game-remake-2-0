class_name MapGraphData
extends Resource

@export var floor_count: int = 0
@export var nodes: Array[MapNodeData] = []

var _node_by_id: Dictionary = {}


func rebuild_index() -> void:
	_node_by_id.clear()
	for node in nodes:
		if node == null:
			continue
		_node_by_id[node.id] = node


func get_node(node_id: String) -> MapNodeData:
	if _node_by_id.is_empty():
		rebuild_index()
	return _node_by_id.get(node_id) as MapNodeData


func get_nodes_for_floor(floor_index: int) -> Array[MapNodeData]:
	var out: Array[MapNodeData] = []
	for node in nodes:
		if node == null:
			continue
		if node.floor_index != floor_index:
			continue
		out.append(node)
	return out


func get_start_node_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for node in get_nodes_for_floor(0):
		ids.append(node.id)
	return ids

