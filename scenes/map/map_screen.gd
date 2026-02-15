class_name MapScreen
extends Control

signal node_selected(node: MapNodeData)

@export var run_state: RunState : set = _set_run_state

@onready var run_label: Label = %RunLabel
@onready var stats_label: Label = %StatsLabel
@onready var hint_label: Label = %HintLabel
@onready var node_list: VBoxContainer = %NodeList

var nodes: Array[MapNodeData] = []


func _set_run_state(value: RunState) -> void:
	if run_state and run_state.changed.is_connected(_refresh_header):
		run_state.changed.disconnect(_refresh_header)

	run_state = value
	if run_state and not run_state.changed.is_connected(_refresh_header):
		run_state.changed.connect(_refresh_header)
	_refresh_header()


func set_nodes(value: Array[MapNodeData]) -> void:
	nodes = value
	if not is_node_ready():
		await ready
	_render_nodes()
	_refresh_header()


func _refresh_header() -> void:
	if not is_node_ready() or not run_state:
		return

	run_label.text = "第 %d 幕 | 层数 %d" % [run_state.act, run_state.floor + 1]
	stats_label.text = "生命 %d/%d   金币 %d" % [run_state.player_stats.health, run_state.player_stats.max_health, run_state.gold]
	hint_label.text = "选择下一个节点，进入该模块的流程。"


func _render_nodes() -> void:
	for child in node_list.get_children():
		child.queue_free()

	for node in nodes:
		var button := Button.new()
		button.text = _format_node_text(node)
		button.custom_minimum_size = Vector2(0, 140)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 30)
		button.pressed.connect(_on_node_pressed.bind(node))
		button.add_theme_color_override("font_color", _node_color(node.type))
		node_list.add_child(button)


func _format_node_text(node: MapNodeData) -> String:
	return "%s\n%s" % [node.title, node.description]


func _node_color(type: MapNodeData.NodeType) -> Color:
	match type:
		MapNodeData.NodeType.ELITE:
			return Color("f9c74f")
		MapNodeData.NodeType.REST:
			return Color("90be6d")
		MapNodeData.NodeType.EVENT:
			return Color("4cc9f0")
		_:
			return Color.WHITE


func _on_node_pressed(node: MapNodeData) -> void:
	node_selected.emit(node)
