extends GutTest

var _buff_system: BuffSystem


func before_all():
	gut.p("BuffSystem 测试套件初始化 - Phase 2 完整状态实现")


func before_each():
	_buff_system = BuffSystem.new()


func after_each():
	if _buff_system:
		_buff_system = null


func test_poison_decrements_each_turn():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_POISON, 3)
	
	_buff_system._run_turn_start_hooks(player)
	
	assert_eq(char_stats.health, 47, "Poison 应在回合开始造成 3 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON), 2, "Poison 应递减到 2")
	
	_buff_system._run_turn_start_hooks(player)
	
	assert_eq(char_stats.health, 45, "Poison 应再造成 2 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_POISON), 1, "Poison 应递减到 1")


func test_weak_reduces_damage_by_25_percent():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_WEAK, 2)
	
	var base_damage := 20
	var modified := _buff_system.get_modified_damage(base_damage, player, Node.new())
	
	assert_eq(modified, 15, "虚弱应减少 25% 伤害（20 -> 15）")


func test_vulnerable_increases_received_damage():
	var enemy: Enemy = partial_double(Enemy).new()
	var enemy_stats: EnemyStats = EnemyStats.new()
	enemy_stats.max_health = 30
	enemy_stats.health = 30
	stub(enemy, 'update_stats').to_do_nothing()
	enemy.stats = enemy_stats
	
	enemy.stats.add_status(BuffSystem.STATUS_VULNERABLE, 1)
	
	var base_damage := 20
	var modified := _buff_system.get_modified_damage(base_damage, Node.new(), enemy)
	
	assert_eq(modified, 30, "易伤应增加 50% 受伤（20 -> 30）")


func test_strength_adds_to_attack_damage():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_STRENGTH, 5)
	
	var base_damage := 10
	var modified := _buff_system.get_modified_damage(base_damage, player, Node.new())
	
	assert_eq(modified, 15, "力量应增加攻击伤害（10 -> 15）")


func test_metallicize_grants_block_on_turn_end():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	char_stats.block = 0
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_METALLICIZE, 4)
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(char_stats.block, 4, "金属化应在回合结束获得格挡")
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(char_stats.block, 8, "金属化应永久生效")


func test_burn_deals_damage_and_removes():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_BURN, 5)
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(char_stats.health, 48, "燃烧应造成 2 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_BURN), 0, "燃烧应消除")


func test_ritual_adds_strength_on_turn_end():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_RITUAL, 2)
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_STRENGTH), 2, "愤怒应增加力量")
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_STRENGTH), 4, "愤怒应永久生效")


func test_regenrate_heals_and_decrements():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 40
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_REGENERATE, 5)
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(char_stats.health, 45, "再生应在回合结束回血")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_REGENERATE), 4, "再生应递减")


func test_constricted_deals_damage_permanent():
	var player: Player = partial_double(Player).new()
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	stub(player, 'update_stats').to_do_nothing()
	player.stats = char_stats
	
	player.stats.add_status(BuffSystem.STATUS_CONSTRICTED, 3)
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(char_stats.health, 47, "束缚应造成 3 点伤害")
	assert_eq(_buff_system.get_status_stack(char_stats, BuffSystem.STATUS_CONSTRICTED), 3, "束缚层数应保持不变")
	
	_buff_system._run_turn_end_hooks(player)
	
	assert_eq(char_stats.health, 44, "束缚应持续造成伤害")


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
	var player: Player = partial_double(Player).new()
	
	var char_stats: CharacterStats = CharacterStats.new()
	char_stats.max_health = 50
	char_stats.health = 50
	
	stub(player, 'update_stats').to_do_nothing()
	
	player.stats = char_stats
	
	player.stats.add_status("strength", 3)
	player.stats.add_status("weak", 2)
	
	var snapshot_before: Dictionary = player.stats.get_status_snapshot()
	assert_eq(snapshot_before.size(), 2, "钩子执行前应有 2 个状态")
	
	_buff_system._run_turn_start_hooks(player)
	
	var snapshot_after: Dictionary = player.stats.get_status_snapshot()
	assert_eq(snapshot_after.size(), 2, "钩子执行后状态数应不变")


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


func test_status_order_includes_all_10():
	assert_eq(BuffSystem.STATUS_ORDER.size(), 10, "应有 10 种状态")


func test_status_labels_exist():
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_STRENGTH), "力")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_DEXTERITY), "敏")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_VULNERABLE), "易")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_WEAK), "弱")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_POISON), "毒")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_BURN), "燃")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_CONSTRICTED), "缚")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_METALLICIZE), "金")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_RITUAL), "怒")
	assert_eq(_buff_system._get_status_label(BuffSystem.STATUS_REGENERATE), "再")
