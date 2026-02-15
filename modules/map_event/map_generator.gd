class_name MapGenerator
extends RefCounted


static func create_act1_seed_map(seed: int, floor: int) -> Array[MapNodeData]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed + floor * 7919

	var nodes: Array[MapNodeData] = []
	nodes.append(_create_node("battle_%d" % floor, MapNodeData.NodeType.BATTLE, "普通战斗", "进入一场标准战斗。", 18))
	nodes.append(_create_node("elite_%d" % floor, MapNodeData.NodeType.ELITE, "精英战斗", "高风险高回报，掉落更多金币。", 35))

	if rng.randf() < 0.5:
		nodes.append(_create_node("rest_%d" % floor, MapNodeData.NodeType.REST, "营火休整", "回复生命值并推进楼层。", 0))
	else:
		nodes.append(_create_node("event_%d" % floor, MapNodeData.NodeType.EVENT, "问号事件", "基础版暂用金币事件占位。", 12))

	return nodes


static func _create_node(id: String, type: MapNodeData.NodeType, title: String, description: String, reward_gold: int) -> MapNodeData:
	var node := MapNodeData.new()
	node.id = id
	node.type = type
	node.title = title
	node.description = description
	node.reward_gold = reward_gold
	return node

