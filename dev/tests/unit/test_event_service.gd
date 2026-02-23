extends GutTest

const EVENT_SERVICE_SCRIPT := preload("res://runtime/modules/map_event/event_service.gd")


func test_card_display_name_prefers_display_name() -> void:
	var card := _build_card("warrior_test", "测试卡")
	assert_eq(EVENT_SERVICE_SCRIPT._card_display_name(card), "测试卡")


func test_card_display_name_fallback_to_id() -> void:
	var card := _build_card("warrior_test", "")
	assert_eq(EVENT_SERVICE_SCRIPT._card_display_name(card), "warrior_test")


func test_upgrade_first_card_returns_display_name() -> void:
	var run_state := _build_run_state()
	var card := _build_card("warrior_slash", "斩击")
	card.upgrade_to = "warrior_slash_plus"
	assert_true(run_state.add_card_to_deck(card))

	var result := EVENT_SERVICE_SCRIPT._upgrade_first_card(run_state)
	assert_eq(result, "斩击")


func test_remove_first_card_returns_display_name() -> void:
	var run_state := _build_run_state()
	assert_true(run_state.add_card_to_deck(_build_card("warrior_slash", "斩击")))
	assert_true(run_state.add_card_to_deck(_build_card("warrior_block", "格挡")))

	var result := EVENT_SERVICE_SCRIPT._remove_first_card(run_state)
	assert_eq(result, "斩击")


func _build_run_state() -> RunState:
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 80
	stats.max_mana = 3
	stats.mana = 3
	stats.starting_deck = CardPile.new()
	stats.deck = CardPile.new()
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()
	run_state.player_stats = stats
	return run_state


func _build_card(card_id: String, display_name: String) -> Card:
	var card := Card.new()
	card.id = card_id
	card.display_name = display_name
	card.cost = 1
	card.type = Card.Type.ATTACK
	card.target = Card.Target.SINGLE_ENEMY
	return card
