extends GutTest

var _engine: EffectStackEngine
var _test_executed: bool = false
var _chain_main_count: int = 0
var _chain_count: int = 0
var _recursive_executed: int = 0


func before_all():
	gut.p("EffectStack 测试套件初始化")


func before_each():
	_engine = EffectStackEngine.new()
	_test_executed = false
	_chain_main_count = 0
	_chain_count = 0
	_recursive_executed = 0


func after_each():
	if _engine:
		_engine = null


func _on_effect_executed(_target: Node) -> void:
	_test_executed = true


func _on_chain_main_executed(_target: Node) -> Dictionary:
	_chain_main_count += 1
	return {
		"chain_effects": [
			{
				"effect": "chain_effect",
				"targets": [_target],
				"apply": _on_chain_executed,
				"priority": 50,
				"effect_type": EffectStackEngine.EffectType.SPECIAL,
			}
		]
	}


func _on_chain_executed(_target: Node) -> void:
	_chain_count += 1


func _on_recursive_chain_executed(target: Node) -> Dictionary:
	_recursive_executed += 1
	return {
		"chain_effects": [
			{
				"effect": "loop_effect",
				"targets": [target],
				"apply": Callable(self, "_on_recursive_chain_executed"),
				"priority": 50,
				"effect_type": EffectStackEngine.EffectType.SPECIAL,
			}
		]
	}


func test_effect_executes_in_priority_order():
	var execution_order: Array[String] = []
	
	var low_priority_target := Node.new()
	var high_priority_target := Node.new()
	
	var high_callable := func(_target: Node) -> void:
		execution_order.append("high")
	var low_callable := func(_target: Node) -> void:
		execution_order.append("low")
	
	_engine._is_processing = true
	
	_engine.enqueue_effect(
		"low_effect",
		[low_priority_target],
		low_callable,
		10,
		EffectStackEngine.EffectType.SPECIAL
	)
	_engine.enqueue_effect(
		"high_effect",
		[high_priority_target],
		high_callable,
		90,
		EffectStackEngine.EffectType.SPECIAL
	)
	
	_engine._is_processing = false
	_engine._process_queue()
	
	assert_eq(execution_order, ["high", "low"], "高优先级效果应先执行")
	
	low_priority_target.free()
	high_priority_target.free()


func test_effect_simple_execution():
	var target := Node.new()
	
	_engine.enqueue_effect(
		"test_effect",
		[target],
		_on_effect_executed,
		50,
		EffectStackEngine.EffectType.SPECIAL
	)
	
	assert_true(_test_executed, "效果应执行")
	target.free()


func test_effect_chain_triggers_correctly():
	var target := Node.new()
	
	_engine._is_processing = true
	_engine.enqueue_effect(
		"main_effect",
		[target],
		_on_chain_main_executed,
		50,
		EffectStackEngine.EffectType.SPECIAL
	)
	
	_engine._is_processing = false
	_engine._process_queue()
	
	assert_eq(_chain_main_count, 1, "主效果应执行一次")
	assert_eq(_chain_count, 1, "链式效果应执行一次")
	
	target.free()


func test_effect_chain_depth_limit_prevents_infinite_loop():
	var target := Node.new()

	_engine.enqueue_effect(
		"test_effect",
		[target],
		Callable(self, "_on_recursive_chain_executed"),
		50,
		EffectStackEngine.EffectType.SPECIAL
	)
	assert_push_error("链式递归深度超过限制", "超过深度限制应输出 push_error")

	assert_eq(_recursive_executed, EffectStackEngine.MAX_CHAIN_DEPTH + 1, "应在达到最大链深后停止继续链式入队")
	assert_eq(_engine.get_queue_size(), 0, "队列应为空")
	target.free()


func test_default_priority_is_50():
	var target := Node.new()
	
	_engine.enqueue_effect(
		"test",
		[target],
		_on_effect_executed
	)
	
	assert_true(_test_executed, "默认优先级效果应执行")
	target.free()


func test_empty_targets_skips_enqueue():
	_engine.enqueue_effect(
		"test",
		[],
		_on_effect_executed
	)
	
	assert_false(_test_executed, "空目标列表应跳过入队")


func test_invalid_callable_skips_enqueue():
	var target := Node.new()
	
	_engine.enqueue_effect(
		"test",
		[target],
		Callable()
	)
	
	assert_eq(_engine.get_queue_size(), 0, "无效 Callable 应跳过入队")
	target.free()


func test_set_current_turn():
	_engine.set_current_turn(5)
	assert_eq(_engine._current_turn, 5, "应设置当前回合")
	
	_engine.set_current_turn(-1)
	assert_eq(_engine._current_turn, 0, "负数回合应被钳制为0")


func test_effect_type_names():
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.DAMAGE), "DAMAGE")
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.BLOCK), "BLOCK")
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.HEAL), "HEAL")
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.DRAW), "DRAW")
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.APPLY_STATUS), "APPLY_STATUS")
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.REMOVE_STATUS), "REMOVE_STATUS")
	assert_eq(_engine._effect_type_name(EffectStackEngine.EffectType.SPECIAL), "SPECIAL")
	assert_eq(_engine._effect_type_name(999), "UNKNOWN")
