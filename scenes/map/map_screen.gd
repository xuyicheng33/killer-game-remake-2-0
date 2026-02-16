class_name MapScreen
extends Control

signal node_selected(node: MapNodeData)

@export var run_state: RunState : set = _set_run_state

@onready var run_label: Label = %RunLabel
@onready var stats_label: Label = %StatsLabel
@onready var hint_label: Label = %HintLabel
@onready var node_list: VBoxContainer = %NodeList

var map_graph: MapGraphData


func _set_run_state(value: RunState) -> void:
	if run_state and run_state.changed.is_connected(_refresh_header):
		run_state.changed.disconnect(_refresh_header)

	run_state = value
	if run_state and not run_state.changed.is_connected(_refresh_header):
		run_state.changed.connect(_refresh_header)
	_render_nodes()
	_refresh_header()


func set_map_graph(value: MapGraphData) -> void:
	map_graph = value
	if not is_node_ready():
		await ready
	_render_nodes()
	_refresh_header()


func _refresh_header() -> void:
	if not is_node_ready() or not run_state:
		return

	run_label.text = "第 %d 幕 | 层数 %d" % [run_state.act, run_state.floor + 1]
	stats_label.text = "生命 %d/%d   金币 %d" % [run_state.player_stats.health, run_state.player_stats.max_health, run_state.gold]
	if run_state.map_reachable_node_ids.is_empty():
		hint_label.text = "当前无可达节点，请开始新一局。"
	else:
		hint_label.text = "仅可选择标记为 [可达] 的节点。"


func _render_nodes() -> void:
	if not is_node_ready():
		return

	for child in node_list.get_children():
		child.queue_free()

	if map_graph == null:
		return

	for floor_index in range(map_graph.floor_count):
		var floor_title := Label.new()
		floor_title.text = _format_floor_label(floor_index)
		floor_title.add_theme_font_size_override("font_size", 22)
		node_list.add_child(floor_title)

		var floor_row := HBoxContainer.new()
		floor_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		floor_row.theme_override_constants.separation = 10
		node_list.add_child(floor_row)

		var floor_nodes := map_graph.get_nodes_for_floor(floor_index)
		for node in floor_nodes:
			var button := Button.new()
			button.text = _format_node_text(node)
			button.custom_minimum_size = Vector2(0, 96)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.add_theme_font_size_override("font_size", 22)
			button.pressed.connect(_on_node_pressed.bind(node))

			var is_reachable := run_state != null and run_state.can_select_map_node(node.id)
			button.disabled = not is_reachable
			button.add_theme_color_override("font_color", _node_color(node.type))
			floor_row.add_child(button)


func _format_node_text(node: MapNodeData) -> String:
	return "[%s] %s\n%s" % [_node_state_tag(node.id), node.title, node.description]


func _format_floor_label(floor_index: int) -> String:
	if floor_index == map_graph.floor_count - 1:
		return "第 %d 层（Boss）" % (floor_index + 1)
	return "第 %d 层" % (floor_index + 1)


func _node_state_tag(node_id: String) -> String:
	if run_state == null:
		return "未知"
	if run_state.can_select_map_node(node_id):
		return "可达"
	if run_state.map_visited_node_ids.has(node_id):
		return "已走"
	return "未达"


func _node_color(type: MapNodeData.NodeType) -> Color:
	match type:
		MapNodeData.NodeType.ELITE:
			return Color("f9c74f")
		MapNodeData.NodeType.REST:
			return Color("90be6d")
		MapNodeData.NodeType.EVENT:
			return Color("4cc9f0")
		MapNodeData.NodeType.SHOP:
			return Color("b8a06e")
		MapNodeData.NodeType.BOSS:
			return Color("ff6b6b")
		_:
			return Color.WHITE


func _on_node_pressed(node: MapNodeData) -> void:
	node_selected.emit(node)
