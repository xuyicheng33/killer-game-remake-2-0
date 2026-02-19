extends GutTest


func before_all() -> void:
	gut.p("SaveService 测试套件初始化")


func test_serialize_relics_includes_extended_fields() -> void:
	var relic := RelicData.new()
	relic.id = "save_relic"
	relic.on_battle_start_heal = 1
	relic.on_card_played_gold = 2
	relic.card_play_interval = 3
	relic.on_player_hit_block = 4
	relic.on_enemy_killed_gold = 5
	relic.on_turn_start_block = 6
	relic.on_turn_end_heal = 7
	relic.shop_discount_percent = 8
	relic.on_run_start_gold = 9
	relic.on_run_start_max_health = 10

	var payload := SaveService._serialize_relics([relic])
	assert_eq(payload.size(), 1, "应序列化 1 个遗物")

	var entry: Dictionary = payload[0]
	assert_eq(int(entry.get("on_enemy_killed_gold", -1)), 5)
	assert_eq(int(entry.get("on_turn_start_block", -1)), 6)
	assert_eq(int(entry.get("on_turn_end_heal", -1)), 7)
	assert_eq(int(entry.get("shop_discount_percent", -1)), 8)
	assert_eq(int(entry.get("on_run_start_gold", -1)), 9)
	assert_eq(int(entry.get("on_run_start_max_health", -1)), 10)


func test_deserialize_relics_restores_extended_fields() -> void:
	var data := [
		{
			"id": "restore_relic",
			"title": "restore",
			"description": "",
			"on_battle_start_heal": 1,
			"on_card_played_gold": 2,
			"card_play_interval": 3,
			"on_player_hit_block": 4,
			"on_enemy_killed_gold": 5,
			"on_turn_start_block": 6,
			"on_turn_end_heal": 7,
			"shop_discount_percent": 8,
			"on_run_start_gold": 9,
			"on_run_start_max_health": 10,
		},
	]

	var relics := SaveService._deserialize_relics(data)
	assert_eq(relics.size(), 1, "应反序列化 1 个遗物")

	var relic: RelicData = relics[0]
	assert_eq(relic.on_enemy_killed_gold, 5)
	assert_eq(relic.on_turn_start_block, 6)
	assert_eq(relic.on_turn_end_heal, 7)
	assert_eq(relic.shop_discount_percent, 8)
	assert_eq(relic.on_run_start_gold, 9)
	assert_eq(relic.on_run_start_max_health, 10)


func test_relic_extended_fields_round_trip() -> void:
	var relic := RelicData.new()
	relic.id = "round_trip_relic"
	relic.on_battle_start_heal = 9
	relic.on_card_played_gold = 8
	relic.card_play_interval = 7
	relic.on_player_hit_block = 6
	relic.on_enemy_killed_gold = 5
	relic.on_turn_start_block = 4
	relic.on_turn_end_heal = 3
	relic.shop_discount_percent = 2
	relic.on_run_start_gold = 1
	relic.on_run_start_max_health = 6

	var serialized := SaveService._serialize_relics([relic])
	var restored := SaveService._deserialize_relics(serialized)
	assert_eq(restored.size(), 1)

	var item: RelicData = restored[0]
	assert_eq(item.on_enemy_killed_gold, relic.on_enemy_killed_gold)
	assert_eq(item.on_turn_start_block, relic.on_turn_start_block)
	assert_eq(item.on_turn_end_heal, relic.on_turn_end_heal)
	assert_eq(item.shop_discount_percent, relic.shop_discount_percent)
	assert_eq(item.on_run_start_gold, relic.on_run_start_gold)
	assert_eq(item.on_run_start_max_health, relic.on_run_start_max_health)


func test_serialize_card_round_trip_preserves_upgrade_to() -> void:
	var card := Card.new()
	card.id = "warrior_finisher_attack"
	card.type = Card.Type.ATTACK
	card.target = Card.Target.SINGLE_ENEMY
	card.cost = 2
	card.keyword_exhaust = true
	card.upgrade_to = "warrior_finisher_attack_plus"
	card.tooltip_text = "Exhaust. Upgrades on consume."

	var serialized := SaveService._serialize_card(card)
	var restored := SaveService._deserialize_card(serialized)

	assert_not_null(restored, "反序列化后卡牌不应为空")
	if restored == null:
		return
	assert_eq(restored.id, card.id)
	assert_eq(restored.upgrade_to, "warrior_finisher_attack_plus", "upgrade_to 字段应保持不变")
