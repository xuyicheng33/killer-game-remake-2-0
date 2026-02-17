class_name MapUIViewModel
extends RefCounted


func project_header(run_state: RunState) -> Dictionary:
	var projection := {
		"run_label": "第 ? 幕 | 层数 ?",
		"stats_label": "生命：--/--   金币：--",
		"hint_label": "加载中...",
	}

	if run_state == null:
		return projection

	projection["run_label"] = "第 %d 幕 | 层数 %d" % [run_state.act, run_state.floor + 1]
	projection["stats_label"] = "生命：%d/%d   金币：%d" % [
		run_state.player_stats.health,
		run_state.player_stats.max_health,
		run_state.gold,
	]

	if run_state.map_reachable_node_ids.is_empty():
		projection["hint_label"] = "当前无可达节点，请开始新一局。"
	else:
		projection["hint_label"] = "仅可选择标记为 [可达] 的节点。"

	return projection


func project_floor_label(floor_index: int, floor_count: int) -> String:
	if floor_index == floor_count - 1:
		return "第 %d 层（Boss）" % (floor_index + 1)
	return "第 %d 层" % (floor_index + 1)


func project_node_text(node: MapNodeData, run_state: RunState) -> Dictionary:
	var projection := {
		"text": "[未知] %s\n%s" % [node.title if node else "?", node.description if node else ""],
		"disabled": true,
		"font_color": Color.WHITE,
		"node_id": "",
	}

	if node == null:
		return projection

	projection["node_id"] = node.id
	projection["text"] = "[%s] %s\n%s" % [_node_state_tag(node.id, run_state), node.title, node.description]

	var is_reachable := run_state != null and run_state.can_select_map_node(node.id)
	projection["disabled"] = not is_reachable
	projection["font_color"] = _node_color(node.type)

	return projection


func _node_state_tag(node_id: String, run_state: RunState) -> String:
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
