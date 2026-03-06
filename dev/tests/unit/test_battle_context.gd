extends GutTest

const BATTLE_CONTEXT_SCRIPT := preload("res://runtime/modules/battle_loop/battle_context.gd")


class SpyPlayerHandler:
	extends PlayerHandler

	var start_battle_calls := 0
	var start_turn_calls := 0
	var end_turn_calls := 0

	func start_battle(_char_stats: CharacterStats) -> void:
		start_battle_calls += 1

	func start_turn() -> void:
		start_turn_calls += 1

	func end_turn() -> void:
		end_turn_calls += 1


class SpyEnemyHandler:
	extends EnemyHandler

	var start_turn_calls := 0
	var reset_enemy_actions_calls := 0

	func start_turn() -> void:
		start_turn_calls += 1

	func reset_enemy_actions() -> void:
		reset_enemy_actions_calls += 1


class DummyPlayer:
	extends Player

	func set_character_stats(value: CharacterStats) -> void:
		stats = value


class DummyEnemy:
	extends Enemy

	func set_enemy_stats(value: EnemyStats) -> void:
		stats = value


var _context: RefCounted


func before_all() -> void:
	gut.p("BattleContext 测试套件初始化")


func before_each() -> void:
	_context = BATTLE_CONTEXT_SCRIPT.new()


func after_each() -> void:
	if _context != null:
		_context.unbind_battle_context()
		_context = null


func test_battle_context_instantiates_independently() -> void:
	assert_not_null(_context, "BattleContext 应该可以独立实例化")
	assert_not_null(_context.get("effect_stack"), "effect_stack 应该被初始化")
	assert_not_null(_context.get("buff_system"), "buff_system 应该被初始化")
	assert_not_null(_context.get("card_zones"), "card_zones 应该被初始化")


func test_multiple_contexts_are_independent() -> void:
	var context1 := BATTLE_CONTEXT_SCRIPT.new()
	var context2 := BATTLE_CONTEXT_SCRIPT.new()
	
	assert_not_same(context1.get("effect_stack"), context2.get("effect_stack"), "不同 context 的 effect_stack 应该是独立实例")
	assert_not_same(context1.get("buff_system"), context2.get("buff_system"), "不同 context 的 buff_system 应该是独立实例")
	assert_not_same(context1.get("card_zones"), context2.get("card_zones"), "不同 context 的 card_zones 应该是独立实例")


func test_is_player_action_window_open_returns_false_initially() -> void:
	assert_false(_context.is_player_action_window_open(), "初始状态下 action window 应该关闭")


func test_buff_system_has_connect_events_method() -> void:
	var buff_system = _context.get("buff_system")
	assert_true(buff_system.has_method("connect_events"), "buff_system 应该有 connect_events 方法")
	assert_true(buff_system.has_method("disconnect_events"), "buff_system 应该有 disconnect_events 方法")


func test_card_zones_has_bind_context_method() -> void:
	var card_zones = _context.get("card_zones")
	assert_true(card_zones.has_method("bind_context"), "card_zones 应该有 bind_context 方法")
	assert_true(card_zones.has_method("unbind_context"), "card_zones 应该有 unbind_context 方法")


func test_context_can_be_garbage_collected() -> void:
	var weak_ref = weakref(_context)
	_context.unbind_battle_context()
	_context = null
	
	assert_null(weak_ref.get_ref(), "context 被置空后应该可以被 GC 回收")


func test_phase_machine_exists() -> void:
	var phase_machine = _context.get("phase_machine")
	assert_not_null(phase_machine, "phase_machine 应该被初始化")


func test_phase_machine_has_required_methods() -> void:
	var phase_machine = _context.get("phase_machine")
	assert_true(phase_machine.has_method("get_phase"), "应有 get_phase 方法")
	assert_true(phase_machine.has_method("get_turn"), "应有 get_turn 方法")
	assert_true(phase_machine.has_method("start"), "应有 start 方法")
	assert_true(phase_machine.has_method("transition_to"), "应有 transition_to 方法")
	assert_true(phase_machine.has_method("check_battle_end"), "应有 check_battle_end 方法")


func test_phase_transitions_in_correct_order() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.INVALID, "初始状态应为 INVALID")
	
	phase_machine.start()
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.DRAW, "start() 后应进入 DRAW")
	
	var transitions := phase_machine.can_transition(BattlePhaseStateMachine.Phase.ACTION)
	assert_true(transitions, "DRAW -> ACTION 应允许")
	
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ACTION)
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.ACTION, "ACTION 转换后阶段应为 ACTION")
	
	transitions = phase_machine.can_transition(BattlePhaseStateMachine.Phase.ENEMY)
	assert_true(transitions, "ACTION -> ENEMY 应允许")
	
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.ENEMY, "ENEMY 转换后阶段应为 ENEMY")
	
	assert_true(phase_machine.can_transition(BattlePhaseStateMachine.Phase.RESOLVE), "ENEMY -> RESOLVE 应允许")
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.RESOLVE)
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.RESOLVE, "RESOLVE 转换后阶段应为 RESOLVE")


func test_buffs_triggered_at_correct_phase() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")

	var player_handler := SpyPlayerHandler.new()
	var enemy_handler := SpyEnemyHandler.new()
	var player := DummyPlayer.new()
	var player_stats := CharacterStats.new()
	player_stats.max_health = 50
	player_stats.health = 50
	player.stats = player_stats

	var enemy := DummyEnemy.new()
	var enemy_stats := EnemyStats.new()
	enemy_stats.max_health = 20
	enemy_stats.health = 20
	enemy.stats = enemy_stats

	phase_machine.bind_turn_handlers(player_handler, enemy_handler)
	phase_machine.bind_context(player, [enemy], _context)

	var events = _get_events_singleton()
	assert_not_null(events, "应能获取 Events 单例")
	if events == null:
		return
	assert_true(events.has_signal("enemy_turn_started"), "应提供 enemy_turn_started 事件")

	phase_machine.start()
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.DRAW, "start() 后应进入 DRAW")
	assert_eq(player_handler.start_battle_calls, 1, "DRAW 阶段应触发玩家开局抽牌流程")

	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ACTION)
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)
	assert_eq(enemy_handler.start_turn_calls, 1, "ENEMY 阶段应驱动敌方行动")

	phase_machine.transition_to(BattlePhaseStateMachine.Phase.RESOLVE)
	assert_eq(player_handler.end_turn_calls, 1, "RESOLVE 阶段应触发弃牌流程")
	assert_eq(enemy_handler.reset_enemy_actions_calls, 0, "弃牌完成前不应重置敌人意图")

	phase_machine.on_resolve_discard_completed()
	assert_eq(enemy_handler.reset_enemy_actions_calls, 1, "弃牌完成后应重置敌人意图")
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.DRAW, "RESOLVE 完成后应回到 DRAW")

	player.free()
	enemy.free()
	player_handler.free()
	enemy_handler.free()


func test_battle_ends_when_player_hp_reaches_zero() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	var result := phase_machine.check_battle_end()
	assert_true(result is Dictionary, "check_battle_end 应返回 Dictionary")
	assert_true(result.has("ended"), "结果应包含 ended 字段")
	assert_true(result.has("result"), "结果应包含 result 字段")
	
	assert_true(result.ended, "无 player 时应结束战斗")
	assert_eq(result.result, BattlePhaseStateMachine.RESULT_DEFEAT, "结果应为 defeat")


func test_phase_machine_does_not_emit_turn_events_directly() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	var events = _get_events_singleton()
	assert_not_null(events, "应能获取 Events 单例")
	if events == null:
		return

	var drawn_count := 0
	var discarded_count := 0
	var player_turn_ended_count := 0
	var enemy_turn_ended_count := 0

	var on_drawn := func() -> void:
		drawn_count += 1
	var on_discarded := func() -> void:
		discarded_count += 1
	var on_player_turn_ended := func() -> void:
		player_turn_ended_count += 1
	var on_enemy_turn_ended := func() -> void:
		enemy_turn_ended_count += 1

	events.connect("player_hand_drawn", on_drawn)
	events.connect("player_hand_discarded", on_discarded)
	events.connect("player_turn_ended", on_player_turn_ended)
	events.connect("enemy_turn_ended", on_enemy_turn_ended)

	phase_machine.start()
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ACTION)
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.RESOLVE)

	if events.is_connected("player_hand_drawn", on_drawn):
		events.disconnect("player_hand_drawn", on_drawn)
	if events.is_connected("player_hand_discarded", on_discarded):
		events.disconnect("player_hand_discarded", on_discarded)
	if events.is_connected("player_turn_ended", on_player_turn_ended):
		events.disconnect("player_turn_ended", on_player_turn_ended)
	if events.is_connected("enemy_turn_ended", on_enemy_turn_ended):
		events.disconnect("enemy_turn_ended", on_enemy_turn_ended)

	assert_eq(drawn_count, 0, "状态机不应直接发出 player_hand_drawn")
	assert_eq(discarded_count, 0, "状态机不应直接发出 player_hand_discarded")
	assert_eq(player_turn_ended_count, 0, "状态机不应直接发出 player_turn_ended")
	assert_eq(enemy_turn_ended_count, 0, "状态机不应直接发出 enemy_turn_ended")


func _get_events_singleton() -> Node:
	if not (Engine.get_main_loop() is SceneTree):
		return null
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null("Events")


func test_killing_all_enemies_triggers_immediate_victory() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	var player := DummyPlayer.new()
	var player_stats := CharacterStats.new()
	player_stats.max_health = 50
	player_stats.health = 50
	player.stats = player_stats

	var enemy := DummyEnemy.new()
	var enemy_stats := EnemyStats.new()
	enemy_stats.max_health = 20
	enemy_stats.health = 0
	enemy.stats = enemy_stats

	phase_machine.bind_context(player, [enemy], _context)
	
	var result := phase_machine.check_battle_end()
	assert_true(result.ended, "所有敌人HP为0时应结束战斗")
	assert_eq(result.result, BattlePhaseStateMachine.RESULT_VICTORY, "结果应为 victory")

	player.free()
	enemy.free()


func test_player_death_triggers_immediate_defeat() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	var player := DummyPlayer.new()
	var player_stats := CharacterStats.new()
	player_stats.max_health = 50
	player_stats.health = 0
	player.stats = player_stats

	var enemy := DummyEnemy.new()
	var enemy_stats := EnemyStats.new()
	enemy_stats.max_health = 20
	enemy_stats.health = 20
	enemy.stats = enemy_stats

	phase_machine.bind_context(player, [enemy], _context)
	
	var result := phase_machine.check_battle_end()
	assert_true(result.ended, "玩家HP为0时应结束战斗")
	assert_eq(result.result, BattlePhaseStateMachine.RESULT_DEFEAT, "结果应为 defeat")

	player.free()
	enemy.free()


func test_battle_continues_when_enemies_alive() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	var player := DummyPlayer.new()
	var player_stats := CharacterStats.new()
	player_stats.max_health = 50
	player_stats.health = 50
	player.stats = player_stats

	var enemy := DummyEnemy.new()
	var enemy_stats := EnemyStats.new()
	enemy_stats.max_health = 20
	enemy_stats.health = 20
	enemy.stats = enemy_stats

	phase_machine.bind_context(player, [enemy], _context)
	
	var result := phase_machine.check_battle_end()
	assert_false(result.ended, "敌人存活时战斗不应结束")

	player.free()
	enemy.free()

