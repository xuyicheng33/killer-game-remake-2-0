extends GutTest


func test_create_returns_handler_with_correct_id() -> void:
	var handler := StatusHandler.create("test_status", "测")
	assert_eq(handler.id, "test_status")
	assert_eq(handler.label, "测")


func test_create_with_default_callables_are_invalid() -> void:
	var handler := StatusHandler.create("test", "T")
	assert_false(handler.on_turn_start.is_valid(), "默认 on_turn_start 应为无效 Callable")
	assert_false(handler.on_turn_end.is_valid(), "默认 on_turn_end 应为无效 Callable")
	assert_false(handler.on_card_played.is_valid(), "默认 on_card_played 应为无效 Callable")
	assert_false(handler.on_entity_hit.is_valid(), "默认 on_entity_hit 应为无效 Callable")


func test_create_with_decays_on_turn_end() -> void:
	var handler := StatusHandler.create("vuln", "易", Callable(), Callable(), true)
	assert_true(handler.decays_on_turn_end, "decays_on_turn_end 应为 true")


func test_create_without_decay_defaults_false() -> void:
	var handler := StatusHandler.create("str", "力")
	assert_false(handler.decays_on_turn_end, "decays_on_turn_end 默认应为 false")


func test_on_turn_start_callback_fires() -> void:
	var fired := [false]
	var handler := StatusHandler.create("poison", "毒",
		func(_t, _s, _stacks): fired[0] = true
	)
	assert_true(handler.on_turn_start.is_valid(), "on_turn_start 应为有效 Callable")
	handler.on_turn_start.call(null, null, 1)
	assert_true(fired[0], "on_turn_start 回调应被触发")


func test_on_turn_end_callback_fires() -> void:
	var value := [0]
	var handler := StatusHandler.create("burn", "燃", Callable(),
		func(_t, _s, stacks): value[0] = stacks,
		true
	)
	assert_true(handler.on_turn_end.is_valid(), "on_turn_end 应为有效 Callable")
	handler.on_turn_end.call(null, null, 5)
	assert_eq(value[0], 5, "on_turn_end 应传入正确 stacks")


func test_on_card_played_callback_fires() -> void:
	var count := [0]
	var handler := StatusHandler.create("rage", "怒", Callable(), Callable(), false,
		func(_t, _s, _stacks): count[0] += 1
	)
	handler.on_card_played.call(null, null, 1)
	assert_eq(count[0], 1, "on_card_played 回调应被触发")


func test_on_entity_hit_callback_fires() -> void:
	var recorded_damage := [0]
	var handler := StatusHandler.create("thorns", "刺", Callable(), Callable(), false, Callable(),
		func(_target, _stats, _stacks, _source, damage): recorded_damage[0] = damage
	)
	handler.on_entity_hit.call(null, null, 1, null, 7)
	assert_eq(recorded_damage[0], 7, "on_entity_hit 应传入正确伤害值")


func test_handler_is_refcounted() -> void:
	var handler := StatusHandler.create("test", "T")
	assert_true(handler is RefCounted, "StatusHandler 应继承 RefCounted")
