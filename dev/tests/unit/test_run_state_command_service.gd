extends GutTest

const COMMAND_SERVICE_SCRIPT := preload("res://runtime/modules/run_meta/run_state_command_service.gd")


func _make_run_state() -> RunState:
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 80
	stats.max_mana = 3
	stats.cards_per_turn = 5
	stats.starting_deck = CardPile.new()
	run_state.init_with_character(stats, 123, "warrior")
	return run_state


func test_spend_and_add_gold() -> void:
	var service = COMMAND_SERVICE_SCRIPT.new()
	var run_state := _make_run_state()

	assert_true(service.spend_gold(run_state, 20), "金币应可扣除")
	assert_eq(run_state.gold, 79, "初始 99 金币，扣 20 后应剩 79")

	service.add_gold(run_state, 5)
	assert_eq(run_state.gold, 84, "加 5 金币后应为 84")


func test_floor_advance() -> void:
	var service = COMMAND_SERVICE_SCRIPT.new()
	var run_state := _make_run_state()

	assert_eq(run_state.floor, 0, "初始层数应为 0")
	service.next_floor(run_state)
	assert_eq(run_state.floor, 1, "next_floor 后应为 1")


func test_deck_add_remove_upgrade() -> void:
	var service = COMMAND_SERVICE_SCRIPT.new()
	var run_state := _make_run_state()

	var card := Card.new()
	card.id = "test_card"
	card.cost = 2
	assert_true(service.add_card_to_deck(run_state, card), "应可加入牌组")

	var cards := run_state.get_deck_cards()
	var index := cards.size() - 1
	assert_true(service.upgrade_card_in_deck_at(run_state, index), "应可升级新加入卡牌")

	var removed: Variant = service.remove_card_from_deck_at(run_state, index)
	assert_not_null(removed, "应可移除牌组中的卡牌")


func test_heal_and_increase_max_health() -> void:
	var service = COMMAND_SERVICE_SCRIPT.new()
	var run_state := _make_run_state()

	run_state.player_stats.health = 50
	service.heal_player(run_state, 10)
	assert_eq(run_state.player_stats.health, 60, "治疗后生命应提升")

	var max_before := run_state.player_stats.max_health
	service.increase_max_health(run_state, 5)
	assert_eq(run_state.player_stats.max_health, max_before + 5, "最大生命应增加")
