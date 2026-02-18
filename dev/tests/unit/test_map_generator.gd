extends GutTest

func before_all():
	gut.p("MapGenerator 测试套件初始化 - Phase 2 15层地图")


func test_map_has_15_layers():
	var graph := MapGenerator.create_act1_seed_graph(12345)
	
	assert_not_null(graph, "地图图数据应不为空")
	assert_eq(graph.floor_count, 15, "地图应有 15 层（14普通+1Boss）")
	
	var max_floor := 0
	for node in graph.nodes:
		if node.floor_index > max_floor:
			max_floor = node.floor_index
	
	assert_eq(max_floor, 14, "最大楼层索引应为 14")


func test_map_has_multiple_paths_to_boss():
	var graph := MapGenerator.create_act1_seed_graph(12345)
	
	assert_true(MapGenerator.has_multiple_paths_to_boss(graph), "应存在多条路径可达Boss")


func test_same_seed_produces_same_map():
	var graph1 := MapGenerator.create_act1_seed_graph(99999)
	var graph2 := MapGenerator.create_act1_seed_graph(99999)
	
	assert_eq(graph1.nodes.size(), graph2.nodes.size(), "相同种子应产生相同数量的节点")
	
	for i in range(graph1.nodes.size()):
		var node1: MapNodeData = graph1.nodes[i]
		var node2: MapNodeData = graph2.nodes[i]
		
		assert_eq(node1.id, node2.id, "节点 ID 应相同")
		assert_eq(node1.type, node2.type, "节点类型应相同")
		assert_eq(node1.floor_index, node2.floor_index, "楼层索引应相同")


func test_different_seed_produces_different_map():
	var graph1 := MapGenerator.create_act1_seed_graph(11111)
	var graph2 := MapGenerator.create_act1_seed_graph(22222)
	
	var has_difference := false
	
	for i in range(min(graph1.nodes.size(), graph2.nodes.size())):
		var node1: MapNodeData = graph1.nodes[i]
		var node2: MapNodeData = graph2.nodes[i]
		
		if node1.type != node2.type:
			has_difference = true
			break
	
	assert_true(has_difference or graph1.nodes.size() != graph2.nodes.size(), "不同种子应产生不同的地图")


func test_boss_node_exists():
	var graph := MapGenerator.create_act1_seed_graph(12345)
	
	var boss_count := 0
	for node in graph.nodes:
		if node.type == MapNodeData.NodeType.BOSS:
			boss_count += 1
	
	assert_eq(boss_count, 1, "应有且仅有 1 个 Boss 节点")


func test_boss_on_final_floor():
	var graph := MapGenerator.create_act1_seed_graph(12345)
	
	for node in graph.nodes:
		if node.type == MapNodeData.NodeType.BOSS:
			assert_eq(node.floor_index, 14, "Boss 应在第 14 层（第 15 层）")


func test_elite_floor_has_elite_probability():
	var total_elites := 0
	var total_nodes := 0
	
	for test_seed in range(100, 110):
		var graph := MapGenerator.create_act1_seed_graph(test_seed)
		
		for node in graph.nodes:
			if node.floor_index >= MapGenerator.ELITE_FLOOR_START and node.floor_index < MapGenerator.NORMAL_FLOOR_COUNT:
				total_nodes += 1
				if node.type == MapNodeData.NodeType.ELITE:
					total_elites += 1
	
	gut.p("精英层总节点: %d, 精英节点: %d" % [total_nodes, total_elites])
	assert_true(total_elites > 0, "多次测试后应有精英节点")


func test_create_act1_seed_map_returns_floor_nodes():
	var nodes := MapGenerator.create_act1_seed_map(12345, 0)
	
	assert_not_null(nodes, "应返回节点数组")
	assert_true(nodes.size() > 0, "应返回非空节点数组")
	
	for node in nodes:
		assert_eq(node.floor_index, 0, "所有节点应在指定楼层")


func test_normal_floor_count_constant():
	assert_eq(MapGenerator.NORMAL_FLOOR_COUNT, 14, "NORMAL_FLOOR_COUNT 应为 14")
