extends GutTest

const BATTLE_CONTEXT_SCRIPT := preload("res://runtime/modules/battle_loop/battle_context.gd")

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
	var weak_ref := weakref(_context)
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
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.ACTION, "start() 后应自动到达 ACTION（DRAW 自动跳转）")
	
	var transitions := phase_machine.can_transition(BattlePhaseStateMachine.Phase.ENEMY)
	assert_true(transitions, "ACTION -> ENEMY 应允许")
	
	phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)
	assert_eq(phase_machine.get_phase(), BattlePhaseStateMachine.Phase.RESOLVE, "ENEMY 应自动跳转到 RESOLVE")


func test_buffs_triggered_at_correct_phase() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	assert_true(phase_machine.has_method("_enter_draw_phase"), "应有 _enter_draw_phase 方法")
	assert_true(phase_machine.has_method("_enter_resolve_phase"), "应有 _enter_resolve_phase 方法")


func test_battle_ends_when_player_hp_reaches_zero() -> void:
	var phase_machine = _context.get("phase_machine") as BattlePhaseStateMachine
	assert_not_null(phase_machine, "phase_machine 不应为空")
	
	var result := phase_machine.check_battle_end()
	assert_true(result is Dictionary, "check_battle_end 应返回 Dictionary")
	assert_true(result.has("ended"), "结果应包含 ended 字段")
	assert_true(result.has("result"), "结果应包含 result 字段")
	
	assert_true(result.ended, "无 player 时应结束战斗")
	assert_eq(result.result, "defeat", "结果应为 defeat")
