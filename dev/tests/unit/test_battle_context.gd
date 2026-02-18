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
