class_name MapScreen
extends Control

signal node_selected(node: MapNodeData)
signal restart_requested

const MAP_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/map_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state

@onready var frame: PanelContainer = %Frame
@onready var run_label: Label = %RunLabel
@onready var stats_label: Label = %StatsLabel
@onready var hint_label: Label = %HintLabel
@onready var restart_run_button: Button = %RestartRunButton
@onready var node_list: VBoxContainer = %NodeList

var map_graph: MapGraphData : set = set_map_graph
var _adapter: MapUIAdapter = MAP_UI_ADAPTER_SCRIPT.new() as MapUIAdapter


func _ready() -> void:
	_connect_signals()
	# 触发初始渲染（run_state 可能在 _ready 之前通过 @export 设置）
	_adapter.refresh()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.node_selected.is_connected(_on_adapter_node_selected):
		_adapter.node_selected.connect(_on_adapter_node_selected)
	if not _adapter.restart_requested.is_connected(_on_adapter_restart_requested):
		_adapter.restart_requested.connect(_on_adapter_restart_requested)
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)

	if not restart_run_button.pressed.is_connected(_adapter.request_restart):
		restart_run_button.pressed.connect(_adapter.request_restart)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)


func _disconnect_signals() -> void:
	if _adapter.node_selected.is_connected(_on_adapter_node_selected):
		_adapter.node_selected.disconnect(_on_adapter_node_selected)
	if _adapter.restart_requested.is_connected(_on_adapter_restart_requested):
		_adapter.restart_requested.disconnect(_on_adapter_restart_requested)
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)

	if restart_run_button.pressed.is_connected(_adapter.request_restart):
		restart_run_button.pressed.disconnect(_adapter.request_restart)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func set_map_graph(value: MapGraphData) -> void:
	map_graph = value
	_adapter.set_map_graph(value)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	run_label.text = str(projection.get("run_label", "第 ? 幕 | 层数 ?"))
	stats_label.text = str(projection.get("stats_label", "生命：--/--   金币：--"))
	hint_label.text = str(projection.get("hint_label", "加载中..."))

	_render_nodes(projection)


func _render_nodes(projection: Dictionary) -> void:
	for child in node_list.get_children():
		child.queue_free()

	if not bool(projection.get("has_map", false)):
		return

	var floor_rows: Variant = projection.get("floor_rows", [])
	if not (floor_rows is Array):
		return

	for floor_row_variant in floor_rows:
		if not (floor_row_variant is Dictionary):
			continue
		var floor_row_data: Dictionary = floor_row_variant

		var floor_title := Label.new()
		floor_title.text = str(floor_row_data.get("floor_label", "第 ? 层"))
		floor_title.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_BODY)
		node_list.add_child(floor_title)

		var floor_row := HBoxContainer.new()
		floor_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		floor_row.add_theme_constant_override("separation", UILayout.LIST_SEPARATION)
		node_list.add_child(floor_row)

		var nodes: Variant = floor_row_data.get("nodes", [])
		if not (nodes is Array):
			continue

		for node_variant in nodes:
			if not (node_variant is Dictionary):
				continue
			var node_data: Dictionary = node_variant

			var node_id := str(node_data.get("node_id", ""))
			var button := Button.new()
			button.text = str(node_data.get("text", "[未知]"))
			button.custom_minimum_size = Vector2(0, UILayout.BTN_HEIGHT_MAP_NODE)
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_BUTTON)
			button.disabled = bool(node_data.get("disabled", true))

			var font_color: Variant = node_data.get("font_color", UIColors.NODE_BATTLE)
			if font_color is Color:
				button.add_theme_color_override("font_color", font_color)

			button.pressed.connect(_on_node_button_pressed.bind(node_id))
			floor_row.add_child(button)


func _on_node_button_pressed(node_id: String) -> void:
	if map_graph == null:
		return
	var node := _find_node_by_id(node_id)
	if node != null:
		_adapter.request_node_selection(node)


func _find_node_by_id(node_id: String) -> MapNodeData:
	if map_graph == null:
		return null
	for floor_index in range(map_graph.floor_count):
		var floor_nodes := map_graph.get_nodes_for_floor(floor_index)
		for node in floor_nodes:
			if node.id == node_id:
				return node
	return null


func _on_adapter_node_selected(node: MapNodeData) -> void:
	node_selected.emit(node)


func _on_adapter_restart_requested() -> void:
	restart_requested.emit()


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	UILayout.apply_frame_layout(frame, viewport_size)
