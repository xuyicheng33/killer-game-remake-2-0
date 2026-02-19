extends GutTest


func before_all() -> void:
	gut.p("RewardEconomy 测试套件初始化")


func _create_run_state(gold: int = 300) -> RunState:
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 70
	stats.health = 70
	stats.max_mana = 3
	stats.starting_deck = CardPile.new()
	stats.deck = CardPile.new()
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()
	run_state.player_stats = stats
	run_state.seed = 123
	run_state.floor = 2
	run_state.map_current_node_id = "f02_l1"
	run_state.gold = gold
	return run_state


func _create_card(id: String) -> Card:
	var card := Card.new()
	card.id = id
	card.type = Card.Type.ATTACK
	card.target = Card.Target.SINGLE_ENEMY
	card.cost = 1
	card.tooltip_text = id
	return card


func test_shop_purchase_relic_deducts_gold() -> void:
	var run_state := _create_run_state(250)
	var relic := RelicData.new()
	relic.id = "shop_relic"
	relic.rarity = "common"

	var ok: bool = ShopOfferGenerator.buy_relic(run_state, relic, 150)

	assert_true(ok, "金币足够时应可购买遗物")
	assert_eq(run_state.gold, 100, "购买后应扣除金币")
	assert_eq(run_state.relics.size(), 1, "遗物应加入 run_state.relics")


func test_shop_purchase_potion_respects_inventory_limit() -> void:
	var run_state := _create_run_state(300)
	var p1 := PotionData.new()
	var p2 := PotionData.new()
	var p3 := PotionData.new()
	run_state.potions = [p1, p2, p3]

	var potion := PotionData.new()
	potion.id = "new_potion"
	var ok: bool = ShopOfferGenerator.buy_potion(run_state, potion, 50)

	assert_false(ok, "药水栏已满时不应购买成功")
	assert_eq(run_state.gold, 300, "购买失败不应扣金币")
	assert_eq(run_state.potions.size(), 3, "药水数量应保持上限")


func test_card_removal_cost_increases_after_first_use() -> void:
	var run_state := _create_run_state(500)
	var card1 := _create_card("remove_1")
	var card2 := _create_card("remove_2")
	run_state.player_stats.deck.add_card(card1)
	run_state.player_stats.deck.add_card(card2)

	var first_price: int = ShopOfferGenerator.calculate_remove_price(run_state)
	var first_ok: bool = ShopOfferGenerator.remove_card(run_state, card1)
	var second_price: int = ShopOfferGenerator.calculate_remove_price(run_state)
	var second_ok: bool = ShopOfferGenerator.remove_card(run_state, card2)

	assert_true(first_ok, "第一次删卡应成功")
	assert_true(second_ok, "第二次删卡应成功")
	assert_eq(first_price, 75, "初始删卡价格应为 75")
	assert_eq(second_price, 100, "第一次删卡后价格应增加到 100")
	assert_eq(run_state.card_removal_count, 2, "删卡计数应递增")


func test_generate_full_offers_returns_dictionary() -> void:
	var run_state := _create_run_state(300)
	var offers: Dictionary = ShopOfferGenerator.generate_full_offers(run_state)

	assert_true(offers is Dictionary, "应返回 Dictionary")
	assert_true(offers.has("cards"), "应包含 cards")
	assert_true(offers.has("relics"), "应包含 relics")
	assert_true(offers.has("potions"), "应包含 potions")
	assert_true(offers.has("remove_price"), "应包含 remove_price")
	assert_true(offers.cards is Array, "cards 应为数组")
	assert_true(offers.relics is Array, "relics 应为数组")
	assert_true(offers.potions is Array, "potions 应为数组")


func test_buy_fails_with_insufficient_gold() -> void:
	var run_state := _create_run_state(40)
	var relic := RelicData.new()
	relic.id = "expensive_relic"

	var ok: bool = ShopOfferGenerator.buy_relic(run_state, relic, 150)

	assert_false(ok, "金币不足时购买应失败")
	assert_eq(run_state.gold, 40, "失败时金币不应改变")
	assert_eq(run_state.relics.size(), 0, "失败时不应添加遗物")


func test_relic_price_by_rarity() -> void:
	var common := RelicData.new()
	common.rarity = "common"
	var uncommon := RelicData.new()
	uncommon.rarity = "uncommon"
	var rare := RelicData.new()
	rare.rarity = "rare"

	assert_eq(ShopOfferGenerator._relic_price(common), 150, "common 遗物应为 150")
	assert_eq(ShopOfferGenerator._relic_price(uncommon), 200, "uncommon 遗物应为 200")
	assert_eq(ShopOfferGenerator._relic_price(rare), 300, "rare 遗物应为 300")


func test_shop_discount_applies_to_card_and_remove_prices() -> void:
	var run_state := _create_run_state(500)
	var relic := RelicData.new()
	relic.id = "discount_relic"
	relic.shop_discount_percent = 20
	run_state.relics = [relic]

	var offers := ShopOfferGenerator.generate_offers(run_state)
	assert_false(offers.is_empty(), "商店报价不应为空")
	assert_eq(int(offers[0].get("price", -1)), 44, "20% 折扣应将 55 金币卡牌降到 44")

	var remove_price := ShopOfferGenerator.calculate_remove_price_for_shop(run_state)
	assert_eq(remove_price, 60, "20% 折扣应将 75 金币删卡降到 60")


func test_shop_flow_generate_offers_contains_card_relic_potion() -> void:
	var run_state := _create_run_state(500)
	var flow := ShopFlowService.new()
	var offers := flow.generate_offers(run_state)

	var type_set := {}
	for offer in offers:
		type_set[str(offer.get("offer_type", ""))] = true

	assert_true(type_set.has("card"), "商店报价应包含卡牌")
	assert_true(type_set.has("relic"), "商店报价应包含遗物")
	assert_true(type_set.has("potion"), "商店报价应包含药水")


func test_shop_flow_can_buy_relic_and_potion() -> void:
	var run_state := _create_run_state(999)
	var flow := ShopFlowService.new()
	var offers := flow.generate_offers(run_state)

	var relic_index := -1
	var potion_index := -1
	for i in range(offers.size()):
		var offer := offers[i]
		var offer_type := str(offer.get("offer_type", ""))
		if offer_type == "relic" and relic_index == -1:
			relic_index = i
		elif offer_type == "potion" and potion_index == -1:
			potion_index = i

	assert_true(relic_index >= 0, "测试前提：应能找到遗物报价")
	assert_true(potion_index >= 0, "测试前提：应能找到药水报价")
	if relic_index < 0 or potion_index < 0:
		return

	var relic_result := flow.execute_buy_offer(run_state, offers, relic_index)
	assert_true(bool(relic_result.get("handled", false)), "购买遗物命令应被处理")
	assert_eq(run_state.relics.size(), 1, "购买遗物后应写入 RunState.relics")

	var refreshed_potion_index := -1
	for i in range(offers.size()):
		if str(offers[i].get("offer_type", "")) == "potion":
			refreshed_potion_index = i
			break

	assert_true(refreshed_potion_index >= 0, "购买遗物后仍应存在药水报价")
	if refreshed_potion_index < 0:
		return

	var potion_result := flow.execute_buy_offer(run_state, offers, refreshed_potion_index)
	assert_true(bool(potion_result.get("handled", false)), "购买药水命令应被处理")
	assert_eq(run_state.potions.size(), 1, "购买药水后应写入 RunState.potions")
