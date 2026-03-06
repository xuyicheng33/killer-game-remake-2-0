extends GutTest

class TrackingBuffSystem:
	extends BuffSystem
	var after_hook_invocations := 0
	var fake_player: Player = null

	func _get_player_node() -> Player:
		return fake_player

	func _run_after_card_played_hooks(target: Node) -> void:
		after_hook_invocations += 1
		super._run_after_card_played_hooks(target)


class FakePlayer extends Player:
	func update_player() -> void:
		pass

	func update_stats() -> void:
		pass


class FakeEnemy extends Enemy:
	func update_enemy() -> void:
		pass

	func update_stats() -> void:
		pass

	func update_action() -> void:
		pass


var _buff_system: BuffSystem


func before_all():
	gut.p("BuffSystem 测试套件初始化 - Phase 2 完整状态实现")


func before_each():
	_buff_system = BuffSystem.new()


func after_each():
	if _buff_system:
		_buff_system = null


func test_poison_decrements_each_turn():
	var player := FakePlayer.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_POISON, 3)

	_buff_system._run_turn_start_hooks(player)

	assert_eq(char_stats.health, 47, "Poison 应在回合开始造成 3 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON), 2, "Poison 应递减到 2")

	_buff_system._run_turn_start_hooks(player)

	assert_eq(char_stats.health, 45, "Poison 应再造成 2 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON), 1, "Poison 应递减到 1")
	player.free()


func test_weak_reduces_damage_by_25_percent():
	var player := FakePlayer.new()
	var dummy_target := Node.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_WEAK, 2)

	var base_damage := 20
	var modified := _buff_system.get_modified_damage(base_damage, player, dummy_target)

	assert_eq(modified, 15, "虚弱应减少 25% 伤害（20 -> 15）")
	player.free()
	dummy_target.free()


func test_vulnerable_increases_received_damage():
	var enemy := FakeEnemy.new()
	var dummy_source := Node.new()
	var enemy_stats: EnemyStats = EnemyStats.new()
	enemy_stats.max_health = 30
	enemy_stats.health = 30
	enemy.stats = enemy_stats

	enemy.stats.add_status(BuffSystem.STATUS_VULNERABLE, 1)

	var base_damage := 20
	var modified := _buff_system.get_modified_damage(base_damage, dummy_source, enemy)

	assert_eq(modified, 30, "易伤应增加 50% 受伤（20 -> 30）")
	enemy.free()
	dummy_source.free()


func test_strength_adds_to_attack_damage():
	var player := FakePlayer.new()
	var dummy_target := Node.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_STRENGTH, 5)

	var base_damage := 10
	var modified := _buff_system.get_modified_damage(base_damage, player, dummy_target)

	assert_eq(modified, 15, "力量应增加攻击伤害（10 -> 15）")
	player.free()
	dummy_target.free()


func test_metallicize_grants_block_on_turn_end():
	var player := FakePlayer.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	char_stats.block = 0
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_METALLICIZE, 4)

	_buff_system._run_turn_end_hooks(player)

	assert_eq(char_stats.block, 4, "金属化应在回合结束获得格挡")

	_buff_system._run_turn_end_hooks(player)

	assert_eq(char_stats.block, 8, "金属化应永久生效")
	player.free()


func test_burn_deals_damage_and_removes():
	var player := FakePlayer.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_BURN, 5)

	_buff_system._run_turn_end_hooks(player)

	assert_eq(char_stats.health, 45, "燃烧应造成 5 点伤害（等于层数）")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_BURN), 4, "燃烧应衰减 1 层")
	player.free()


func test_ritual_adds_strength_on_turn_end():
	var player := FakePlayer.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_RITUAL, 2)

	_buff_system._run_turn_end_hooks(player)

	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_STRENGTH), 2, "愤怒应增加力量")

	_buff_system._run_turn_end_hooks(player)

	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_STRENGTH), 4, "愤怒应永久生效")
	player.free()


func test_regenrate_heals_and_decrements():
	var player := FakePlayer.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 40
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_REGENERATE, 5)

	_buff_system._run_turn_end_hooks(player)

	assert_eq(char_stats.health, 45, "再生应在回合结束回血")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_REGENERATE), 4, "再生应递减")
	player.free()


func test_constricted_deals_damage_permanent():
	var player := FakePlayer.new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats

	player.stats.add_status(BuffSystem.STATUS_CONSTRICTED, 3)

	_buff_system._run_turn_end_hooks(player)

	assert_eq(char_stats.health, 47, "束缚应造成 3 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_CONSTRICTED), 3, "束缚层数应保持不变")

	_buff_system._run_turn_end_hooks(player)

	assert_eq(char_stats.health, 44, "束缚应持续造成伤害")
	player.free()


func test_status_badges_includes_new_statuses():
	var stats := CharacterStats.new()
	stats.max_health = 50
	stats.health = 50

	stats.add_status(BuffSystem.STATUS_STRENGTH, 2)
	stats.add_status(BuffSystem.STATUS_BURN, 1)
	stats.add_status(BuffSystem.STATUS_METALLICIZE, 3)

	var badges := _buff_system.get_status_badges(stats)

	assert_eq(badges.size(), 3, "应有 3 个状态徽章")

	var ids: Array[String] = []
	for badge in badges:
		ids.append(badge["id"])

	assert_true(ids.has(BuffSystem.STATUS_STRENGTH), "应包含力量")
	assert_true(ids.has(BuffSystem.STATUS_BURN), "应包含燃烧")
	assert_true(ids.has(BuffSystem.STATUS_METALLICIZE), "应包含金属化")


func test_turn_start_hooks_dispatches_for_player():
	var player := FakePlayer.new()

	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50

	player.stats = char_stats

	player.stats.add_status("strength", 3)
	player.stats.add_status("weak", 2)

	var snapshot_before: Dictionary = player.stats.get_status_snapshot()
	assert_eq(snapshot_before.size(), 2, "钩子执行前应有 2 个状态")

	_buff_system._run_turn_start_hooks(player)

	var snapshot_after: Dictionary = player.stats.get_status_snapshot()
	assert_eq(snapshot_after.size(), 2, "钩子执行后状态数应不变")
	player.free()


func test_turn_start_hook_fires_for_registered_status():
	var player := FakePlayer.new()
	var char_stats := CharacterStats.new()
	char_stats.max_health = 30
	char_stats.health = 30
	player.stats = char_stats
	player.stats.add_status(BuffSystem.STATUS_POISON, 3)

	_buff_system._run_turn_start_hooks(player)

	assert_eq(char_stats.health, 27, "注册为回合开始触发的 poison 状态应生效")
	assert_eq(
		_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON),
		2,
		"回合开始触发后 poison 应递减"
	)
	player.free()


func test_after_card_played_hook_fires_on_attack_card():
	var tracking := TrackingBuffSystem.new()
	var player := FakePlayer.new()
	var char_stats := CharacterStats.new()
	char_stats.max_health = 30
	char_stats.health = 30
	player.stats = char_stats
	tracking.fake_player = player

	var attack_card := Card.new()
	attack_card.id = "test_attack"
	attack_card.type = Card.Type.ATTACK
	attack_card.target = Card.Target.SINGLE_ENEMY

	tracking._on_card_played(attack_card)

	assert_eq(tracking.after_hook_invocations, 1, "打出攻击牌后应触发 after_card_played 钩子分发")

	tracking.fake_player = null
	player.free()


func test_turn_start_hooks_handles_null_target():
	_buff_system._run_turn_start_hooks(null)
	assert_true(true, "空目标不应导致崩溃")


func test_after_card_played_hooks_handles_null_target():
	_buff_system._run_after_card_played_hooks(null)
	assert_true(true, "空目标不应导致崩溃")


func test_turn_start_hooks_handles_no_stats():
	var node: Node = Node.new()
	_buff_system._run_turn_start_hooks(node)
	assert_true(true, "无 stats 的节点不应导致崩溃")
	node.free()


func test_status_registry_includes_all_10():
	assert_eq(_buff_system._status_order.size(), 10, "应有 10 种状态")
	assert_true(_buff_system.has_status(BuffSystem.STATUS_STRENGTH), "应包含 strength")
	assert_true(_buff_system.has_status(BuffSystem.STATUS_REGENERATE), "应包含 regenerate")


func test_status_labels_exist():
	var badges_stats := Stats.new()
	badges_stats.max_health = 100
	badges_stats.health = 100
	for status_id in _buff_system._status_order:
		badges_stats.add_status(status_id, 1)
	var badges := _buff_system.get_status_badges(badges_stats)
	assert_eq(badges.size(), 10, "应返回 10 个徽章")
	for badge in badges:
		assert_true(badge.label != "?", "状态 '%s' 的标签不应为 '?'" % badge.id)


func test_run_after_card_played_hooks_does_not_crash() -> void:
	var player := FakePlayer.new()
	var char_stats := CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats
	# 添加各种状态
	char_stats.add_status(BuffSystem.STATUS_STRENGTH, 2)
	char_stats.add_status(BuffSystem.STATUS_POISON, 3)

	var health_before := char_stats.health
	var poison_before := _buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON)

	_buff_system.bind_combatants(player, [])
	# 应该不会崩溃，且状态不应被意外修改
	_buff_system._run_after_card_played_hooks(player)
	_buff_system.unbind_combatants()

	# 验证状态未被意外修改（当前所有状态在出牌后无特殊行为）
	assert_eq(char_stats.health, health_before, "出牌后钩子不应影响血量")
	assert_eq(
		_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON),
		poison_before,
		"出牌后钩子不应影响毒状态"
	)
	player.free()


func test_on_entity_hit_with_null_target() -> void:
	_buff_system.on_entity_hit(null, null, 0)
	# 应该安全处理 null
	assert_true(true, "空目标不应导致崩溃")


func test_on_entity_hit_with_valid_target() -> void:
	var player := FakePlayer.new()
	var char_stats := CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	player.stats = char_stats
	var dummy_source := Node.new()

	_buff_system.on_entity_hit(player, dummy_source, 10)
	# 应该不会崩溃
	assert_eq(char_stats.health, 50, "当前无受击触发状态，血量应不变")

	dummy_source.free()
	player.free()
