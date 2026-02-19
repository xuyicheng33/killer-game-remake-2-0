extends GutTest

func before_all():
	gut.p("种子一致性测试套件初始化 - Phase 4")


func test_same_seed_generates_same_map() -> void:
	var seed := 12345

	var graph1 := MapGenerator.create_act1_seed_graph(seed)
	var graph2 := MapGenerator.create_act1_seed_graph(seed)

	assert_eq(graph1.floor_count, graph2.floor_count, "相同种子应产生相同楼层数")
	assert_eq(graph1.nodes.size(), graph2.nodes.size(), "相同种子应产生相同数量的节点")

	# 验证节点 ID 和类型一致
	for i in range(graph1.nodes.size()):
		var node1: MapNodeData = graph1.nodes[i]
		var node2: MapNodeData = graph2.nodes[i]

		assert_eq(node1.id, node2.id, "节点 ID 应相同")
		assert_eq(node1.type, node2.type, "节点类型应相同")
		assert_eq(node1.floor_index, node2.floor_index, "楼层索引应相同")
		assert_eq(node1.lane_index, node2.lane_index, "通道索引应相同")


func test_rng_state_export_import() -> void:
	RunRng.begin_run(99999)

	# 使用 randf/randi_range 会创建并注册流到 _streams
	var _value1 := RunRng.randf("test_stream_a")
	var _value2 := RunRng.randi_range("test_stream_b", 1, 100)

	var state1 := RunRng.export_run_state()

	# 验证流已被注册
	var streams1: Dictionary = state1.get("streams", {})
	assert_true(streams1.has("test_stream_a"), "test_stream_a 应在流状态中")
	assert_true(streams1.has("test_stream_b"), "test_stream_b 应在流状态中")

	# 继续使用流，改变状态
	var _value3 := RunRng.randf("test_stream_a")

	# 恢复状态
	var restore_success := RunRng.restore_run_state(state1)
	assert_true(restore_success, "恢复状态应成功")

	var state2 := RunRng.export_run_state()

	# 验证种子一致
	assert_eq(state1.get("run_seed"), state2.get("run_seed"), "种子应一致")

	# 验证流状态一致
	var streams2: Dictionary = state2.get("streams", {})

	for key in streams1.keys():
		assert_eq(streams1.get(key), streams2.get(key), "流 %s 状态应一致" % key)


func test_rng_produces_deterministic_results() -> void:
	RunRng.begin_run(42)

	# 第一次生成随机数
	var rng1 := RunRng.create_seeded_rng(42, "determinism_test")
	var results1 := []
	for i in range(10):
		results1.append(rng1.randi_range(1, 100))

	# 第二次使用相同种子生成
	var rng2 := RunRng.create_seeded_rng(42, "determinism_test")
	var results2 := []
	for i in range(10):
		results2.append(rng2.randi_range(1, 100))

	# 验证结果一致
	for i in range(results1.size()):
		assert_eq(results1[i], results2[i], "相同种子应产生相同的随机序列")


func test_different_stream_keys_produce_different_sequences() -> void:
	RunRng.begin_run(777)

	var rng_a := RunRng.create_seeded_rng(777, "stream_a")
	var rng_b := RunRng.create_seeded_rng(777, "stream_b")

	var value_a := rng_a.randi()
	var value_b := rng_b.randi()

	# 不同流键应产生不同的随机序列
	assert_ne(value_a, value_b, "不同流键应产生不同的随机数")


func test_rng_begin_run_clears_streams() -> void:
	RunRng.begin_run(100)
	# 使用 randf/randi_range 会创建并注册流
	var _unused1 := RunRng.randf("test_stream")

	var state1 := RunRng.export_run_state()
	assert_true(state1.get("streams", {}).has("test_stream"), "流应存在")

	# 开始新局应清除所有流
	RunRng.begin_run(200)
	var state2 := RunRng.export_run_state()
	assert_false(state2.get("streams", {}).has("test_stream"), "新局应清除旧流")


func test_map_generator_uses_seed_correctly() -> void:
	# 验证 MapGenerator 确实使用种子
	var graph1 := MapGenerator.create_act1_seed_graph(11111)
	var graph2 := MapGenerator.create_act1_seed_graph(22222)

	var all_same := true
	for i in range(min(graph1.nodes.size(), graph2.nodes.size())):
		if graph1.nodes[i].type != graph2.nodes[i].type:
			all_same = false
			break

	# 不同种子应该产生至少部分不同的地图
	# 注意：由于概率分布，某些节点可能偶然相同
	# 我们只验证整个地图不完全相同
	assert_false(all_same, "不同种子应产生不同的地图配置")
