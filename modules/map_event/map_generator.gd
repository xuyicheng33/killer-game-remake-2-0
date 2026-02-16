class_name MapGenerator
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://global/run_rng.gd")

const NORMAL_FLOOR_COUNT := 5
const LANE_COUNT := 3


static func create_act1_seed_graph(seed: int) -> MapGraphData:
	var rng: RandomNumberGenerator = RUN_RNG_SCRIPT.create_seeded_rng(seed + 104_729, "map_generator_act1")

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

	# Final floor: boss.
	var boss_node := _create_node(
		"boss_f%02d" % NORMAL_FLOOR_COUNT,
		MapNodeData.NodeType.BOSS,
		NORMAL_FLOOR_COUNT,
		1
	)
	graph.nodes.append(boss_node)

	# Connect normal floors.
	for floor_index in range(NORMAL_FLOOR_COUNT - 1):
		var current_floor: Array = lane_nodes_by_floor[floor_index]
		var next_floor: Array = lane_nodes_by_floor[floor_index + 1]

		for lane_index in range(LANE_COUNT):
			var from_node := current_floor[lane_index] as MapNodeData
			var targets := PackedStringArray()
			targets.append((next_floor[lane_index] as MapNodeData).id)

			if lane_index > 0 and rng.randf() < 0.5:
				targets.append((next_floor[lane_index - 1] as MapNodeData).id)
			if lane_index < LANE_COUNT - 1 and rng.randf() < 0.5:
				targets.append((next_floor[lane_index + 1] as MapNodeData).id)

			# Ensure uniqueness.
			var unique_targets := PackedStringArray()
			for target_id in targets:
				if not unique_targets.has(target_id):
					unique_targets.append(target_id)
			from_node.next_node_ids = unique_targets

	# Last normal floor connects to boss.
	var last_floor: Array = lane_nodes_by_floor[NORMAL_FLOOR_COUNT - 1]
	for node in last_floor:
		var map_node := node as MapNodeData
		map_node.next_node_ids = PackedStringArray([boss_node.id])

	graph.rebuild_index()
	return graph


static func create_act1_seed_map(seed: int, floor: int) -> Array[MapNodeData]:
	# Compatibility helper for old call sites.
	var graph := create_act1_seed_graph(seed)
	var clamped_floor := clampi(floor, 0, graph.floor_count - 1)
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

	if floor_index <= 1:
		if roll < 0.6:
			return MapNodeData.NodeType.BATTLE
		if roll < 0.8:
			return MapNodeData.NodeType.EVENT
		if roll < 0.92:
			return MapNodeData.NodeType.REST
		return MapNodeData.NodeType.SHOP

	if roll < 0.45:
		return MapNodeData.NodeType.BATTLE
	if roll < 0.62:
		return MapNodeData.NodeType.EVENT
	if roll < 0.76:
		return MapNodeData.NodeType.REST
	if roll < 0.88:
		return MapNodeData.NodeType.SHOP
	return MapNodeData.NodeType.ELITE


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
			return "商店占位节点（B3 再实现交易流程）。"
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
