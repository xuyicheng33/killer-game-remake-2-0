extends GutTest


class FakeRelicSystem:
	extends RefCounted
	var _trigger_counts: Dictionary = {}

	func get_relic_trigger_count(relic_id: String, trigger_type: String) -> int:
		var key := "%s:%s" % [relic_id, trigger_type]
		return _trigger_counts.get(key, 0)

	func increment_relic_trigger_count(relic_id: String, trigger_type: String) -> void:
		var key := "%s:%s" % [relic_id, trigger_type]
		_trigger_counts[key] = _trigger_counts.get(key, 0) + 1


class FakeTarget:
	extends Node
	var stats: Stats

	func _init(p_stats: Stats = null) -> void:
		stats = p_stats


func test_check_interval_zero_always_true() -> void:
	assert_true(RelicConditionChecker.check_interval(0, 0), "间隔 0 应始终返回 true")
	assert_true(RelicConditionChecker.check_interval(5, 0), "间隔 0 应始终返回 true")


func test_check_interval_matches() -> void:
	assert_true(RelicConditionChecker.check_interval(3, 3), "3 % 3 == 0 应返回 true")
	assert_false(RelicConditionChecker.check_interval(4, 3), "4 % 3 != 0 应返回 false")
	assert_true(RelicConditionChecker.check_interval(6, 3), "6 % 3 == 0 应返回 true")


func test_can_trigger_unlimited() -> void:
	assert_true(
		RelicConditionChecker.can_trigger(null, "relic", "type", 0),
		"max_triggers=0 应表示无限制"
	)


func test_can_trigger_within_limit() -> void:
	var system := FakeRelicSystem.new()
	assert_true(
		RelicConditionChecker.can_trigger(system, "relic_a", "on_hit", 3),
		"计数为 0 时应可触发"
	)


func test_can_trigger_at_limit() -> void:
	var system := FakeRelicSystem.new()
	system.increment_relic_trigger_count("relic_a", "on_hit")
	system.increment_relic_trigger_count("relic_a", "on_hit")
	system.increment_relic_trigger_count("relic_a", "on_hit")
	assert_false(
		RelicConditionChecker.can_trigger(system, "relic_a", "on_hit", 3),
		"达到上限时应返回 false"
	)


func test_can_trigger_null_system() -> void:
	assert_false(
		RelicConditionChecker.can_trigger(null, "relic", "type", 3),
		"null system 应返回 false"
	)


func test_check_and_consume_increments() -> void:
	var system := FakeRelicSystem.new()
	var result := RelicConditionChecker.check_and_consume_trigger(system, "relic_b", "on_kill", 2)
	assert_true(result, "第一次触发应成功")
	assert_eq(system.get_relic_trigger_count("relic_b", "on_kill"), 1, "触发计数应增加")

	result = RelicConditionChecker.check_and_consume_trigger(system, "relic_b", "on_kill", 2)
	assert_true(result, "第二次触发应成功")

	result = RelicConditionChecker.check_and_consume_trigger(system, "relic_b", "on_kill", 2)
	assert_false(result, "第三次触发应失败（超过上限）")


func test_check_hp_below_percent() -> void:
	var stats := CharacterStats.new()
	stats.max_health = 100
	stats.health = 30
	var target := FakeTarget.new(stats)

	assert_true(
		RelicConditionChecker.check_hp_below_percent(target, 0.5),
		"30/100=0.3 应低于 0.5"
	)
	assert_false(
		RelicConditionChecker.check_hp_below_percent(target, 0.2),
		"30/100=0.3 不应低于 0.2"
	)
	target.free()


func test_check_hp_null_target() -> void:
	assert_false(
		RelicConditionChecker.check_hp_below_percent(null, 0.5),
		"null 目标应返回 false"
	)


func test_check_hp_no_stats() -> void:
	var target := Node.new()
	assert_false(
		RelicConditionChecker.check_hp_below_percent(target, 0.5),
		"无 stats 的节点应返回 false"
	)
	target.free()
