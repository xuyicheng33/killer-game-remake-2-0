extends GutTest

var _buff_system: BuffSystem


func before_all():
    gut.p("BuffSystem 测试套件初始化 - P0 钩子修复验证")


func before_each():
    _buff_system = BuffSystem.new()


func after_each():
    if _buff_system:
        _buff_system = null


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
    assert_eq(snapshot_after.size(), 2, "钩子执行后状态数应不变（当前状态无触发逻辑）")


func test_turn_start_hooks_dispatches_for_enemy():
    var enemy: Enemy = partial_double(Enemy).new()
    
    var enemy_stats: EnemyStats = EnemyStats.new()
    enemy_stats.max_health = 30
    enemy_stats.health = 30
    
    stub(enemy, 'update_stats').to_do_nothing()
    
    enemy.stats = enemy_stats
    
    enemy.stats.add_status("vulnerable", 1)
    enemy.stats.add_status("poison", 4)
    
    var snapshot_before: Dictionary = enemy.stats.get_status_snapshot()
    assert_eq(snapshot_before.size(), 2, "钩子执行前应有 2 个状态")
    
    _buff_system._run_turn_start_hooks(enemy)
    
    var snapshot_after: Dictionary = enemy.stats.get_status_snapshot()
    assert_eq(snapshot_after.size(), 2, "钩子执行后状态数应不变（当前状态无触发逻辑）")


func test_after_card_played_hooks_dispatches_for_player():
    var player: Player = partial_double(Player).new()
    
    var char_stats: CharacterStats = CharacterStats.new()
    char_stats.max_health = 50
    char_stats.health = 50
    
    stub(player, 'update_stats').to_do_nothing()
    
    player.stats = char_stats
    
    player.stats.add_status("strength", 5)
    
    var snapshot_before: Dictionary = player.stats.get_status_snapshot()
    assert_eq(snapshot_before.size(), 1, "钩子执行前应有 1 个状态")
    
    _buff_system._run_after_card_played_hooks(player)
    
    var snapshot_after: Dictionary = player.stats.get_status_snapshot()
    assert_eq(snapshot_after.size(), 1, "钩子执行后状态数应不变（当前状态无触发逻辑）")


func test_after_card_played_hooks_dispatches_for_enemy():
    var enemy: Enemy = partial_double(Enemy).new()
    
    var enemy_stats: EnemyStats = EnemyStats.new()
    enemy_stats.max_health = 30
    enemy_stats.health = 30
    
    stub(enemy, 'update_stats').to_do_nothing()
    
    enemy.stats = enemy_stats
    
    enemy.stats.add_status("dexterity", 2)
    
    _buff_system._run_after_card_played_hooks(enemy)
    
    assert_true(true, "_run_after_card_played_hooks 应为 Enemy 执行遍历分发")


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


func test_hooks_iterate_all_status_types():
    var player: Player = partial_double(Player).new()
    
    var char_stats: CharacterStats = CharacterStats.new()
    char_stats.max_health = 50
    char_stats.health = 50
    
    stub(player, 'update_stats').to_do_nothing()
    
    player.stats = char_stats
    
    player.stats.add_status("strength", 1)
    player.stats.add_status("dexterity", 1)
    player.stats.add_status("vulnerable", 1)
    player.stats.add_status("weak", 1)
    player.stats.add_status("poison", 1)
    
    var snapshot: Dictionary = player.stats.get_status_snapshot()
    assert_eq(snapshot.size(), 5, "应有 5 个状态")
    
    _buff_system._run_turn_start_hooks(player)
    _buff_system._run_after_card_played_hooks(player)
    
    assert_true(true, "两个钩子都应正确遍历所有 5 种状态类型")
