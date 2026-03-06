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


var _context: BattleContext
var _player: DummyPlayer
var _enemy: DummyEnemy
var _player_handler: SpyPlayerHandler
var _enemy_handler: SpyEnemyHandler


func before_each() -> void:
	_context = BATTLE_CONTEXT_SCRIPT.new()

	_player = DummyPlayer.new()
	var pstats := CharacterStats.new()
	pstats.max_health = 80
	pstats.health = 80
	pstats.max_mana = 3
	pstats.mana = 3
	pstats.cards_per_turn = 5
	pstats.starting_deck = CardPile.new()
	pstats.deck = CardPile.new()
	pstats.draw_pile = CardPile.new()
	pstats.discard = CardPile.new()
	_player.stats = pstats

	_enemy = DummyEnemy.new()
	var estats := EnemyStats.new()
	estats.max_health = 40
	estats.health = 40
	_enemy.stats = estats

	_player_handler = SpyPlayerHandler.new()
	_enemy_handler = SpyEnemyHandler.new()

	_context.phase_machine.bind_turn_handlers(_player_handler, _enemy_handler)
	_context.phase_machine.bind_context(_player, [_enemy], _context)


func after_each() -> void:
	if _context != null:
		_context.unbind_battle_context()
		_context = null
	if _player != null:
		_player.free()
		_player = null
	if _enemy != null:
		_enemy.free()
		_enemy = null
	if _player_handler != null:
		_player_handler.free()
		_player_handler = null
	if _enemy_handler != null:
		_enemy_handler.free()
		_enemy_handler = null


func _advance_full_turn() -> void:
	var pm := _context.phase_machine
	pm.transition_to(BattlePhaseStateMachine.Phase.ACTION)
	pm.transition_to(BattlePhaseStateMachine.Phase.ENEMY)
	pm.transition_to(BattlePhaseStateMachine.Phase.RESOLVE)
	pm.on_resolve_discard_completed()


func test_three_full_turns_advance_turn_counter() -> void:
	var pm := _context.phase_machine
	pm.start()

	for i in range(3):
		_advance_full_turn()

	assert_eq(pm.get_turn(), 4, "3 轮循环后应进入第 4 回合的 DRAW")
	assert_eq(pm.get_phase(), BattlePhaseStateMachine.Phase.DRAW, "应回到 DRAW 阶段")


func test_burn_damage_proportional_to_stacks() -> void:
	var buff := _context.buff_system
	_player.stats.set_status("burn", 5)

	var hp_before := _player.stats.health
	buff._run_turn_end_hooks(_player)

	assert_eq(_player.stats.health, hp_before - 5, "5 层燃烧应造成 5 点伤害")
	assert_eq(_player.stats.get_status("burn"), 4, "燃烧应衰减 1 层")


func test_burn_decays_to_zero_over_turns() -> void:
	var buff := _context.buff_system
	_player.stats.set_status("burn", 2)

	buff._run_turn_end_hooks(_player)
	assert_eq(_player.stats.get_status("burn"), 1, "第 1 轮后燃烧应为 1 层")

	buff._run_turn_end_hooks(_player)
	assert_eq(_player.stats.get_status("burn"), 0, "第 2 轮后燃烧应为 0 层")

	var hp_after_2 := _player.stats.health
	buff._run_turn_end_hooks(_player)
	assert_eq(_player.stats.health, hp_after_2, "0 层燃烧不应造成伤害")


func test_poison_triggers_at_turn_start() -> void:
	_enemy.stats.set_status("poison", 3)

	var hp_before := _enemy.stats.health
	_context.buff_system._run_turn_start_hooks(_enemy)

	assert_eq(_enemy.stats.health, hp_before - 3, "3 层中毒应造成 3 点伤害")
	assert_eq(_enemy.stats.get_status("poison"), 2, "中毒应衰减 1 层")


func test_weak_and_vulnerable_decay_at_turn_end() -> void:
	_player.stats.set_status("weak", 2)
	_player.stats.set_status("vulnerable", 1)

	_context.buff_system._run_turn_end_hooks(_player)

	assert_eq(_player.stats.get_status("weak"), 1, "虚弱应衰减 1 层")
	assert_eq(_player.stats.get_status("vulnerable"), 0, "易伤应衰减至 0")


func test_battle_ends_when_enemy_killed() -> void:
	_enemy.stats.health = 0

	var result := _context.phase_machine.check_battle_end()
	assert_true(result.ended, "敌人死亡时战斗应结束")
	assert_eq(result.result, BattlePhaseStateMachine.RESULT_VICTORY, "应判定为胜利")


func test_battle_ends_when_player_killed() -> void:
	_player.stats.health = 0

	var result := _context.phase_machine.check_battle_end()
	assert_true(result.ended, "玩家死亡时战斗应结束")
	assert_eq(result.result, BattlePhaseStateMachine.RESULT_DEFEAT, "应判定为失败")


func test_effect_stack_processes_in_priority_order() -> void:
	var engine := _context.effect_stack
	var execution_order: Array[String] = []

	engine.enqueue_effect(
		"trigger", [_player] as Array[Node],
		func(_t):
			engine.enqueue_effect(
				"low_priority", [_player] as Array[Node],
				func(_t2): execution_order.append("low"), 10)
			engine.enqueue_effect(
				"high_priority", [_player] as Array[Node],
				func(_t2): execution_order.append("high"), 90)
			engine.enqueue_effect(
				"mid_priority", [_player] as Array[Node],
				func(_t2): execution_order.append("mid"), 50),
		100
	)

	assert_eq(execution_order.size(), 3, "应执行 3 个效果")
	assert_eq(execution_order[0], "high", "最高优先级应先执行")
	assert_eq(execution_order[1], "mid", "中优先级其次")
	assert_eq(execution_order[2], "low", "最低优先级最后")


func test_effect_stack_chain_effects() -> void:
	var engine := _context.effect_stack
	var log: Array[String] = []

	engine.enqueue_effect(
		"parent_effect", [_player] as Array[Node],
		func(_t):
			log.append("parent")
			engine.enqueue_effect(
				"child_effect", [_player] as Array[Node],
				func(_t2): log.append("child"),
				50,
				EffectStackEngine.EffectType.SPECIAL,
				null, 0, 1
			),
		50
	)

	assert_eq(log.size(), 2, "父子效果都应执行")
	assert_eq(log[0], "parent", "父效果先执行")
	assert_eq(log[1], "child", "子效果后执行")


func test_full_combat_simulation_player_wins() -> void:
	_enemy.stats.health = 10
	_player.stats.set_status("strength", 5)
	_enemy.stats.set_status("poison", 4)

	var pm := _context.phase_machine
	pm.start()

	_context.buff_system._run_turn_start_hooks(_enemy)
	assert_eq(_enemy.stats.health, 6, "4 层中毒对 10 HP 敌人应剩 6 HP")

	_context.buff_system._run_turn_start_hooks(_enemy)
	assert_eq(_enemy.stats.health, 3, "3 层中毒应再造 3 点")

	_context.buff_system._run_turn_start_hooks(_enemy)
	assert_eq(_enemy.stats.health, 1, "2 层中毒应再造 2 点")

	_context.buff_system._run_turn_start_hooks(_enemy)
	assert_true(_enemy.stats.health <= 0, "1 层中毒应击杀 1 HP 敌人")

	var result := pm.check_battle_end()
	assert_true(result.ended, "敌人死亡后战斗应结束")
	assert_eq(result.result, BattlePhaseStateMachine.RESULT_VICTORY, "应判定为胜利")
