class_name MapGenerator
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

const NORMAL_FLOOR_COUNT := 14
const LANE_COUNT := 3
const ELITE_FLOOR_START := 7


static func create_act1_seed_graph(run_seed: int) -> MapGraphData:
	var rng: RandomNumberGenerator = RUN_RNG_SCRIPT.create_seeded_rng(run_seed + 104_729, "map_generator_act1")

	var graph := MapGraphData.new()
	graph.floor_count = NORMAL_FLOOR_COUNT + 1

	var lane_nodes_by_floor: Array[Array] = []
	for floor_index in range(NORMAL_FLOOR_COUNT):
		var floor_nodes: Array = []
		for lane_index in range(LANE_COUNT):
			var node_type := _roll_node_type(rng, floor_index)
			var node_id := "f%02d_l%d" % [floor_index, lane_index]
			var node := _create_node(node_id, node_type, floor_index, lane_index)
			floor_nodes.append(node)
			graph.nodes.append(node)
		lane_nodes_by_floor.append(floor_nodes)

	var boss_node := _create_node(
		"boss_f%02d" % NORMAL_FLOOR_COUNT,
		MapNodeData.NodeType.BOSS,
		NORMAL_FLOOR_COUNT,
		1
	)
	graph.nodes.append(boss_node)

	for floor_index in range(NORMAL_FLOOR_COUNT - 1):
		var current_floor: Array = lane_nodes_by_floor[floor_index]
		var next_floor: Array = lane_nodes_by_floor[floor_index + 1]

		for lane_index in range(LANE_COUNT):
			var from_node := current_floor[lane_index] as MapNodeData
			from_node.next_node_ids = _pick_next_targets(next_floor, lane_index, rng)

	var last_floor: Array = lane_nodes_by_floor[NORMAL_FLOOR_COUNT - 1]
	for node in last_floor:
		var map_node := node as MapNodeData
		map_node.next_node_ids = PackedStringArray([boss_node.id])

	graph.rebuild_index()
	return graph


static func create_act1_seed_map(run_seed: int, floor_index: int) -> Array[MapNodeData]:
	var graph := create_act1_seed_graph(run_seed)
	var clamped_floor := clampi(floor_index, 0, graph.floor_count - 1)
	return graph.get_nodes_for_floor(clamped_floor)


static func _create_node(id: String, type: MapNodeData.NodeType, floor_index: int, lane_index: int) -> MapNodeData:
	var node := MapNodeData.new()
	node.id = id
	node.type = type
	node.floor_index = floor_index
	node.lane_index = lane_index
	node.title = _title_for_type(type)
	node.description = _description_for_type(type)
	node.reward_gold = _reward_for_type(type)
	return node


static func _roll_node_type(rng: RandomNumberGenerator, floor_index: int) -> MapNodeData.NodeType:
	var roll := rng.randf()
	var is_elite_floor := floor_index >= ELITE_FLOOR_START

	if is_elite_floor:
		if roll < 0.35:
			return MapNodeData.NodeType.BATTLE
		if roll < 0.63:
			return MapNodeData.NodeType.EVENT
		if roll < 0.75:
			return MapNodeData.NodeType.REST
		if roll < 0.80:
			return MapNodeData.NodeType.SHOP
		return MapNodeData.NodeType.ELITE
	else:
		if roll < 0.45:
			return MapNodeData.NodeType.BATTLE
		if roll < 0.53:
			return MapNodeData.NodeType.ELITE
		if roll < 0.68:
			return MapNodeData.NodeType.REST
		if roll < 0.73:
			return MapNodeData.NodeType.SHOP
		return MapNodeData.NodeType.EVENT


static func _title_for_type(type: MapNodeData.NodeType) -> String:
	match type:
		MapNodeData.NodeType.BATTLE:
			return "普通战斗"
		MapNodeData.NodeType.ELITE:
			return "精英战斗"
		MapNodeData.NodeType.REST:
			return "营火休整"
		MapNodeData.NodeType.SHOP:
			return "商店节点"
		MapNodeData.NodeType.EVENT:
			return "问号事件"
		MapNodeData.NodeType.BOSS:
			return "Boss 战"
		_:
			return "未知节点"


static func _description_for_type(type: MapNodeData.NodeType) -> String:
	match type:
		MapNodeData.NodeType.BATTLE:
			return "进入一场标准战斗。"
		MapNodeData.NodeType.ELITE:
			return "高风险高回报，掉落更多金币。"
		MapNodeData.NodeType.REST:
			return "回复生命值并推进楼层。"
		MapNodeData.NodeType.SHOP:
			return "购买卡牌、遗物或药水，或支付金币删除卡牌。"
		MapNodeData.NodeType.EVENT:
			return "基础版问号事件占位。"
		MapNodeData.NodeType.BOSS:
			return "章节守关战斗。"
		_:
			return "暂无描述。"


static func _reward_for_type(type: MapNodeData.NodeType) -> int:
	match type:
		MapNodeData.NodeType.BATTLE:
			return 18
		MapNodeData.NodeType.ELITE:
			return 35
		MapNodeData.NodeType.EVENT:
			return 12
		MapNodeData.NodeType.BOSS:
			return 80
		_:
			return 0


static func _pick_next_targets(next_floor: Array, lane_index: int, rng: RandomNumberGenerator) -> PackedStringArray:
	var targets := PackedStringArray()
	var same_lane_node := next_floor[lane_index] as MapNodeData
	if same_lane_node == null:
		return targets

	targets.append(same_lane_node.id)

	var side_candidates: Array[String] = []
	if lane_index > 0:
		var left_node := next_floor[lane_index - 1] as MapNodeData
		if left_node != null:
			side_candidates.append(left_node.id)
	if lane_index < LANE_COUNT - 1:
		var right_node := next_floor[lane_index + 1] as MapNodeData
		if right_node != null:
			side_candidates.append(right_node.id)

	# 每节点最多 2 条出边，满足“下一层 1-2 个节点”的规划约束。
	if not side_candidates.is_empty() and rng.randf() < 0.55:
		var side_index := rng.randi_range(0, side_candidates.size() - 1)
		var side_id := side_candidates[side_index]
		if not targets.has(side_id):
			targets.append(side_id)

	return targets


static func has_multiple_paths_to_boss(graph: MapGraphData) -> bool:
	if graph == null or graph.nodes.is_empty():
		return false
	
	var start_nodes: Array[MapNodeData] = []
	for node in graph.nodes:
		if node.floor_index == 0:
			start_nodes.append(node)
	
	if start_nodes.size() < 2:
		return false
	
	var boss_node: MapNodeData = null
	for node in graph.nodes:
		if node.type == MapNodeData.NodeType.BOSS:
			boss_node = node
			break
	
	if boss_node == null:
		return false

	var all_paths: Array[PackedStringArray] = []
	for start_node in start_nodes:
		_collect_paths_to_target(start_node, boss_node.id, graph, PackedStringArray(), all_paths)

	if all_paths.size() < 2:
		return false

	for i in range(all_paths.size()):
		for j in range(i + 1, all_paths.size()):
			if _are_paths_node_disjoint(all_paths[i], all_paths[j], boss_node.id):
				return true
	return false


static func _can_reach_node(from: MapNodeData, target_id: String, graph: MapGraphData, visited: Dictionary) -> bool:
	if from == null:
		return false
	if from.id == target_id:
		return true
	if visited.has(from.id):
		return false
	
	visited[from.id] = true
	
	for next_id in from.next_node_ids:
		var next_node: MapNodeData = graph.get_node(next_id)
		if next_node != null and _can_reach_node(next_node, target_id, graph, visited):
			return true
	
	return false


static func _collect_paths_to_target(
	current: MapNodeData,
	target_id: String,
	graph: MapGraphData,
	path: PackedStringArray,
	out_paths: Array[PackedStringArray]
) -> void:
	if current == null:
		return

	var next_path := path.duplicate()
	next_path.append(current.id)
	if current.id == target_id:
		out_paths.append(next_path)
		return

	for next_id in current.next_node_ids:
		var next_node: MapNodeData = graph.get_node(next_id)
		if next_node == null:
			continue
		_collect_paths_to_target(next_node, target_id, graph, next_path, out_paths)


static func _are_paths_node_disjoint(path_a: PackedStringArray, path_b: PackedStringArray, boss_id: String) -> bool:
	var intermediates_a := _intermediate_node_set(path_a, boss_id)
	var intermediates_b := _intermediate_node_set(path_b, boss_id)
	for node_id in intermediates_a.keys():
		if intermediates_b.has(node_id):
			return false
	return true


static func _intermediate_node_set(path: PackedStringArray, boss_id: String) -> Dictionary:
	var out := {}
	if path.size() <= 2:
		return out

	for index in range(1, path.size() - 1):
		var node_id := String(path[index])
		if node_id == boss_id:
			continue
		out[node_id] = true
	return out
