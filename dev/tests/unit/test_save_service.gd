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


func test_card_removal_count_survives_save_load() -> void:
	# 创建一个带有 card_removal_count 的 RunState
	var run_state := RunState.new()
	run_state.character_id = "warrior"
	run_state.seed = 12345
	run_state.card_removal_count = 5
	run_state.floor = 3
	run_state.gold = 100
	run_state.run_start_relics_applied = true

	# 序列化
	var payload := SaveService._serialize_run_state(run_state)

	# 验证序列化包含 card_removal_count
	assert_true(payload.has("card_removal_count"), "序列化应包含 card_removal_count")
	assert_eq(int(payload.get("card_removal_count", 0)), 5, "序列化的 card_removal_count 应为 5")

	# 创建一个基础属性用于反序列化（需要 starting_deck）
	var base_stats := CharacterStats.new()
	base_stats.max_health = 80
	base_stats.health = 80
	base_stats.starting_deck = CardPile.new()
	base_stats.max_mana = 3
	base_stats.cards_per_turn = 5

	# 反序列化
	var restored := SaveService._deserialize_run_state(payload, base_stats)

	assert_not_null(restored, "反序列化后的 RunState 不应为空")
	if restored == null:
		return
	assert_eq(restored.card_removal_count, 5, "反序列化后 card_removal_count 应保持为 5")


func test_card_removal_count_default_value_on_missing_field() -> void:
	# 模拟旧版存档（无 card_removal_count 字段）
	var payload := {
		"save_version": 3,
		"character_id": "warrior",
		"seed": 12345,
		"act": 1,
		"floor": 2,
		"gold": 50,
		"relic_capacity": 6,
		"potion_capacity": 3,
		"map_current_node_id": "",
		"map_reachable_node_ids": [],
		"map_visited_node_ids": [],
		"map_graph": {},
		"player_stats": {"health": 80, "max_health": 80, "mana": 3, "max_mana": 3, "block": 0, "cards_per_turn": 5, "deck": []},
		"relics": [],
		"potions": [],
		"run_start_relics_applied": true,
		# 注意：没有 card_removal_count 字段
	}

	var base_stats := CharacterStats.new()
	base_stats.max_health = 80
	base_stats.health = 80
	base_stats.starting_deck = CardPile.new()
	base_stats.max_mana = 3
	base_stats.cards_per_turn = 5

	var restored := SaveService._deserialize_run_state(payload, base_stats)

	assert_not_null(restored, "反序列化后的 RunState 不应为空")
	if restored == null:
		return
	assert_eq(restored.card_removal_count, 0, "缺失 card_removal_count 字段时应默认为 0")
