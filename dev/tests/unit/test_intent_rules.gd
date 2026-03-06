extends GutTest


func _make_action(type: int, name: StringName, performable: bool, weight: float, index: int) -> IntentActionData:
	return IntentActionData.from_values(type, name, performable, weight, index)


func _make_chance(name: StringName, weight: float, index: int) -> IntentActionData:
	return _make_action(IntentActionData.ActionType.CHANCE_BASED, name, true, weight, index)


func _make_conditional(name: StringName, performable: bool, index: int) -> IntentActionData:
	return _make_action(IntentActionData.ActionType.CONDITIONAL, name, performable, 0.0, index)


func test_conditional_takes_priority_over_weighted() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 5.0, 0),
		_make_conditional(&"mega_block", true, 1),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"", 0, false)
	assert_eq(result.action_name, &"mega_block", "条件动作应优先于权重动作")


func test_unperformable_conditional_is_skipped() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 5.0, 0),
		_make_conditional(&"mega_block", false, 1),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"", 0, false)
	assert_eq(result.action_name, &"attack", "不可执行的条件动作应被跳过")


func test_disallow_consecutive_filters_last_action() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 5.0, 0),
		_make_chance(&"block", 5.0, 1),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"attack", 0, true)
	assert_eq(result.action_name, &"block", "禁止连续应过滤上一动作")


func test_disallow_consecutive_does_not_empty_pool() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 5.0, 0),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"attack", 0, true)
	assert_not_null(result, "只有一个动作时禁止连续不应导致空结果")
	assert_eq(result.action_name, &"attack", "唯一动作应被选中")


func test_empty_actions_returns_null() -> void:
	var actions: Array[IntentActionData] = []
	var result := EnemyIntentRules.pick_next_action(actions, &"", 0, false)
	assert_null(result, "空动作列表应返回 null")


func test_weighted_selection_returns_valid_action() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 3.0, 0),
		_make_chance(&"block", 7.0, 1),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"", 0, false)
	assert_not_null(result, "加权选择应返回非空结果")
	assert_true(
		result.action_name == &"attack" or result.action_name == &"block",
		"结果应为 attack 或 block"
	)


func test_source_index_preserved() -> void:
	var actions: Array[IntentActionData] = [
		_make_conditional(&"mega", true, 42),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"", 0, false)
	assert_eq(result.source_index, 42, "source_index 应被保留")


func test_pick_first_conditional_returns_first_performable() -> void:
	var actions: Array[IntentActionData] = [
		_make_conditional(&"cond_a", false, 0),
		_make_conditional(&"cond_b", true, 1),
		_make_conditional(&"cond_c", true, 2),
	]
	var result := EnemyIntentRules.pick_first_conditional_action(actions, &"", 0, false)
	assert_eq(result.action_name, &"cond_b", "应返回第一个可执行的条件动作")


func test_pick_first_conditional_returns_null_when_none() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 5.0, 0),
	]
	var result := EnemyIntentRules.pick_first_conditional_action(actions, &"", 0, false)
	assert_null(result, "无条件动作时应返回 null")


func test_zero_weight_falls_back_to_first() -> void:
	var actions: Array[IntentActionData] = [
		_make_chance(&"attack", 0.0, 0),
		_make_chance(&"block", 0.0, 1),
	]
	var result := EnemyIntentRules.pick_next_action(actions, &"", 0, false)
	assert_not_null(result, "零权重应回退到第一个动作")
