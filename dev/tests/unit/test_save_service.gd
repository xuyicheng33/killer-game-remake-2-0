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


func test_run_state_full_roundtrip() -> void:
	# 创建完整的 RunState 并测试所有字段
	var base_stats := CharacterStats.new()
	base_stats.max_health = 100
	base_stats.health = 100
	base_stats.starting_deck = CardPile.new()
	base_stats.max_mana = 3
	base_stats.cards_per_turn = 5

	var run_state := RunState.new()
	run_state.init_with_character(base_stats, 54321, "warrior")

	# 设置所有字段
	run_state.act = 2
	run_state.floor = 7
	run_state.gold = 250
	run_state.relic_capacity = 8
	run_state.potion_capacity = 4
	run_state.card_removal_count = 3
	run_state.run_start_relics_applied = true

	# 设置地图进度
	run_state.map_current_node_id = "f05_l1"
	run_state.map_reachable_node_ids = PackedStringArray(["f06_l0", "f06_l1", "f06_l2"])
	run_state.map_visited_node_ids = PackedStringArray(["f00_l0", "f01_l1", "f02_l0", "f03_l1", "f04_l0", "f05_l1"])

	# 添加遗物
	var relic := RelicData.new()
	relic.id = "test_relic"
	relic.title = "测试遗物"
	relic.description = "测试用遗物"
	relic.on_battle_start_heal = 5
	relic.shop_discount_percent = 15
	run_state.relics.append(relic)

	# 添加药水
	var potion := PotionData.new()
	potion.id = "test_potion"
	potion.title = "测试药水"
	potion.description = "测试用药水"
	potion.effect_type = PotionData.EffectType.HEAL
	potion.value = 20
	run_state.potions.append(potion)

	# 设置玩家状态
	run_state.player_stats.health = 75
	run_state.player_stats.max_health = 100
	run_state.player_stats.block = 10
	run_state.player_stats.set_status("strength", 2)
	run_state.player_stats.set_status("dexterity", 1)

	# 添加卡牌到牌组
	var card := Card.new()
	card.id = "test_strike"
	card.type = Card.Type.ATTACK
	card.target = Card.Target.SINGLE_ENEMY
	card.cost = 1
	run_state.player_stats.deck.add_card(card)

	# 序列化
	var payload := SaveService._serialize_run_state(run_state)

	# 验证关键字段存在
	assert_true(payload.has("save_version"), "应有 save_version")
	assert_true(payload.has("character_id"), "应有 character_id")
	assert_true(payload.has("seed"), "应有 seed")
	assert_true(payload.has("act"), "应有 act")
	assert_true(payload.has("floor"), "应有 floor")
	assert_true(payload.has("gold"), "应有 gold")
	assert_true(payload.has("relic_capacity"), "应有 relic_capacity")
	assert_true(payload.has("potion_capacity"), "应有 potion_capacity")
	assert_true(payload.has("card_removal_count"), "应有 card_removal_count")
	assert_true(payload.has("run_start_relics_applied"), "应有 run_start_relics_applied")
	assert_true(payload.has("map_current_node_id"), "应有 map_current_node_id")
	assert_true(payload.has("map_reachable_node_ids"), "应有 map_reachable_node_ids")
	assert_true(payload.has("map_visited_node_ids"), "应有 map_visited_node_ids")
	assert_true(payload.has("map_graph"), "应有 map_graph")
	assert_true(payload.has("player_stats"), "应有 player_stats")
	assert_true(payload.has("relics"), "应有 relics")
	assert_true(payload.has("potions"), "应有 potions")

	# 创建新的 base_stats 用于反序列化
	var restore_base := CharacterStats.new()
	restore_base.max_health = 100
	restore_base.starting_deck = CardPile.new()
	restore_base.max_mana = 3
	restore_base.cards_per_turn = 5

	# 反序列化
	var restored := SaveService._deserialize_run_state(payload, restore_base)

	assert_not_null(restored, "反序列化不应返回 null")
	if restored == null:
		return

	# 验证所有字段
	assert_eq(restored.character_id, "warrior", "character_id 应恢复")
	assert_eq(restored.seed, 54321, "seed 应恢复")
	assert_eq(restored.act, 2, "act 应恢复")
	assert_eq(restored.floor, 7, "floor 应恢复")
	assert_eq(restored.gold, 250, "gold 应恢复")
	assert_eq(restored.relic_capacity, 8, "relic_capacity 应恢复")
	assert_eq(restored.potion_capacity, 4, "potion_capacity 应恢复")
	assert_eq(restored.card_removal_count, 3, "card_removal_count 应恢复")
	assert_eq(restored.run_start_relics_applied, true, "run_start_relics_applied 应恢复")
	assert_eq(restored.map_current_node_id, "f05_l1", "map_current_node_id 应恢复")

	# 验证 map_reachable_node_ids
	assert_eq(restored.map_reachable_node_ids.size(), 3, "map_reachable_node_ids 应有 3 个元素")
	assert_true(restored.map_reachable_node_ids.has("f06_l0"), "map_reachable_node_ids 应包含 f06_l0")
	assert_true(restored.map_reachable_node_ids.has("f06_l1"), "map_reachable_node_ids 应包含 f06_l1")
	assert_true(restored.map_reachable_node_ids.has("f06_l2"), "map_reachable_node_ids 应包含 f06_l2")

	# 验证 map_visited_node_ids
	assert_eq(restored.map_visited_node_ids.size(), 6, "map_visited_node_ids 应有 6 个元素")

	# 验证遗物
	assert_eq(restored.relics.size(), 1, "应有 1 个遗物")
	if restored.relics.size() > 0:
		assert_eq(restored.relics[0].id, "test_relic", "遗物 id 应恢复")
		assert_eq(restored.relics[0].on_battle_start_heal, 5, "遗物 on_battle_start_heal 应恢复")
		assert_eq(restored.relics[0].shop_discount_percent, 15, "遗物 shop_discount_percent 应恢复")

	# 验证药水
	assert_eq(restored.potions.size(), 1, "应有 1 个药水")
	if restored.potions.size() > 0:
		assert_eq(restored.potions[0].id, "test_potion", "药水 id 应恢复")
		assert_eq(restored.potions[0].effect_type, PotionData.EffectType.HEAL, "药水 effect_type 应恢复")
		assert_eq(restored.potions[0].value, 20, "药水 value 应恢复")

	# 验证玩家状态
	assert_not_null(restored.player_stats, "player_stats 不应为 null")
	if restored.player_stats != null:
		assert_eq(restored.player_stats.health, 75, "health 应恢复")
		assert_eq(restored.player_stats.max_health, 100, "max_health 应恢复")
		assert_eq(restored.player_stats.block, 10, "block 应恢复")
		assert_eq(restored.player_stats.get_status("strength"), 2, "strength 状态应恢复")
		assert_eq(restored.player_stats.get_status("dexterity"), 1, "dexterity 状态应恢复")
		assert_eq(restored.player_stats.deck.cards.size(), 1, "牌组应有 1 张卡")

	# 验证地图图
	assert_not_null(restored.map_graph, "map_graph 不应为 null")
	if restored.map_graph != null:
		assert_true(restored.map_graph.floor_count > 0, "map_graph 应有 floor_count")


func test_map_graph_roundtrip() -> void:
	# 测试地图图单独序列化/反序列化
	var graph := MapGraphData.new()
	graph.floor_count = 5

	var node1 := MapNodeData.new()
	node1.id = "test_node_1"
	node1.type = MapNodeData.NodeType.BATTLE
	node1.title = "战斗节点"
	node1.description = "测试战斗"
	node1.reward_gold = 20
	node1.floor_index = 0
	node1.lane_index = 0
	node1.next_node_ids = PackedStringArray(["test_node_2"])

	var node2 := MapNodeData.new()
	node2.id = "test_node_2"
	node2.type = MapNodeData.NodeType.ELITE
	node2.title = "精英节点"
	node2.description = "测试精英"
	node2.reward_gold = 50
	node2.floor_index = 1
	node2.lane_index = 0
	node2.next_node_ids = PackedStringArray()

	graph.nodes.append(node1)
	graph.nodes.append(node2)

	# 序列化
	var serialized := SaveService._serialize_map_graph(graph)
	assert_eq(serialized.get("floor_count", 0), 5, "floor_count 应正确序列化")

	var nodes_variant: Variant = serialized.get("nodes", [])
	assert_true(nodes_variant is Array, "nodes 应为数组")
	if nodes_variant is Array:
		var nodes: Array = nodes_variant
		assert_eq(nodes.size(), 2, "应有 2 个节点")

	# 反序列化
	var restored := SaveService._deserialize_map_graph(serialized)
	assert_not_null(restored, "反序列化不应返回 null")
	if restored == null:
		return

	assert_eq(restored.floor_count, 5, "floor_count 应恢复")
	assert_eq(restored.nodes.size(), 2, "应有 2 个节点")

	var restored_node1: MapNodeData = null
	var restored_node2: MapNodeData = null
	for node in restored.nodes:
		if node.id == "test_node_1":
			restored_node1 = node
		elif node.id == "test_node_2":
			restored_node2 = node

	assert_not_null(restored_node1, "节点1 应存在")
	assert_not_null(restored_node2, "节点2 应存在")

	if restored_node1 != null:
		assert_eq(restored_node1.type, MapNodeData.NodeType.BATTLE, "节点1 类型应恢复")
		assert_eq(restored_node1.reward_gold, 20, "节点1 reward_gold 应恢复")
		assert_eq(restored_node1.next_node_ids.size(), 1, "节点1 应有 1 个 next_node_id")

	if restored_node2 != null:
		assert_eq(restored_node2.type, MapNodeData.NodeType.ELITE, "节点2 类型应恢复")


func test_player_stats_with_statuses_roundtrip() -> void:
	# 测试带状态的玩家状态序列化
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 60
	stats.max_mana = 3
	stats.mana = 2
	stats.cards_per_turn = 5
	stats.block = 5
	stats.starting_deck = CardPile.new()
	stats.deck = CardPile.new()

	# 添加多种状态
	stats.set_status("strength", 3)
	stats.set_status("dexterity", 2)
	stats.set_status("weak", 1)
	stats.set_status("vulnerable", 2)

	# 添加卡牌
	var card1 := Card.new()
	card1.id = "strike"
	card1.type = Card.Type.ATTACK
	card1.cost = 1
	stats.deck.add_card(card1)

	var card2 := Card.new()
	card2.id = "defend"
	card2.type = Card.Type.SKILL
	card2.cost = 1
	stats.deck.add_card(card2)

	# 序列化
	var serialized := SaveService._serialize_player_stats(stats)

	# 验证序列化结果
	assert_eq(serialized.get("health", 0), 60, "health 应正确序列化")
	assert_eq(serialized.get("max_health", 0), 80, "max_health 应正确序列化")
	assert_eq(serialized.get("mana", 0), 2, "mana 应正确序列化")
	assert_eq(serialized.get("max_mana", 0), 3, "max_mana 应正确序列化")
	assert_eq(serialized.get("block", 0), 5, "block 应正确序列化")
	assert_eq(serialized.get("cards_per_turn", 0), 5, "cards_per_turn 应正确序列化")

	var statuses: Dictionary = serialized.get("statuses", {})
	assert_eq(statuses.get("strength", 0), 3, "strength 应正确序列化")
	assert_eq(statuses.get("dexterity", 0), 2, "dexterity 应正确序列化")
	assert_eq(statuses.get("weak", 0), 1, "weak 应正确序列化")
	assert_eq(statuses.get("vulnerable", 0), 2, "vulnerable 应正确序列化")

	var deck_variant: Variant = serialized.get("deck", [])
	assert_true(deck_variant is Array, "deck 应为数组")
	if deck_variant is Array:
		var deck: Array = deck_variant
		assert_eq(deck.size(), 2, "牌组应有 2 张卡")
