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

	assert_eq(run_state.current_floor, 0, "初始层数应为 0")
	service.next_floor(run_state)
	assert_eq(run_state.current_floor, 1, "next_floor 后应为 1")


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


func test_add_relic_fails_when_capacity_full() -> void:
	var run_state := _make_run_state()
	run_state.relic_capacity = 1
	var relic1 := RelicData.new()
	relic1.id = "relic_a"
	var relic2 := RelicData.new()
	relic2.id = "relic_b"
	assert_true(run_state.add_relic(relic1), "第 1 个遗物应添加成功")
	assert_false(run_state.add_relic(relic2), "超出容量应添加失败")


func test_add_relic_fails_on_duplicate_id() -> void:
	var run_state := _make_run_state()
	var relic := RelicData.new()
	relic.id = "unique_relic"
	assert_true(run_state.add_relic(relic), "首次添加应成功")
	var dup := RelicData.new()
	dup.id = "unique_relic"
	assert_false(run_state.add_relic(dup), "重复 ID 应添加失败")


func test_add_potion_fails_when_capacity_full() -> void:
	var run_state := _make_run_state()
	run_state.potion_capacity = 1
	var p1 := PotionData.new()
	p1.id = "potion_a"
	var p2 := PotionData.new()
	p2.id = "potion_b"
	assert_true(run_state.add_potion(p1), "第 1 个药水应添加成功")
	assert_false(run_state.add_potion(p2), "超出容量应添加失败")


func test_spend_gold_fails_when_insufficient() -> void:
	var run_state := _make_run_state()
	run_state.gold = 10
	assert_false(run_state.spend_gold(20), "余额不足应返回 false")
	assert_eq(run_state.gold, 10, "金币不应被扣除")


func test_remove_card_from_deck_at_out_of_bounds() -> void:
	var run_state := _make_run_state()
	var removed := run_state.remove_card_from_deck_at(999)
	assert_null(removed, "越界索引应返回 null")
	var removed_neg := run_state.remove_card_from_deck_at(-1)
	assert_null(removed_neg, "负索引应返回 null")
