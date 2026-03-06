extends GutTest

const MAP_GENERATOR_SCRIPT := preload("res://runtime/modules/map_event/map_generator.gd")


func _make_minimal_payload() -> Dictionary:
	return {
		"seed": 99999,
		"character_id": "warrior",
		"act": 1,
		"floor": 3,
		"gold": 150,
		"player_stats": {
			"max_health": 80,
			"health": 60,
			"max_mana": 3,
			"mana": 3,
			"cards_per_turn": 5,
			"deck": [],
		},
	}


func test_deserialize_basic_fields() -> void:
	var base_stats := CharacterStats.new()
	base_stats.max_health = 80
	base_stats.health = 80
	base_stats.max_mana = 3
	base_stats.deck = CardPile.new()
	base_stats.draw_pile = CardPile.new()
	base_stats.discard = CardPile.new()

	var payload := _make_minimal_payload()
	var state := RunStateDeserializer.deserialize_run_state(payload, base_stats, MAP_GENERATOR_SCRIPT)

	assert_not_null(state, "反序列化结果不应为 null")
	assert_eq(state.run_seed, 99999, "种子应正确恢复")
	assert_eq(state.current_floor, 3, "楼层应正确恢复")
	assert_eq(state.gold, 150, "金币应正确恢复")


func test_deserialize_player_stats() -> void:
	var base_stats := CharacterStats.new()
	base_stats.max_health = 100
	base_stats.health = 100
	base_stats.max_mana = 3
	base_stats.deck = CardPile.new()
	base_stats.draw_pile = CardPile.new()
	base_stats.discard = CardPile.new()

	var payload := _make_minimal_payload()
	payload["player_stats"]["health"] = 42
	payload["player_stats"]["max_health"] = 80
	var state := RunStateDeserializer.deserialize_run_state(payload, base_stats, MAP_GENERATOR_SCRIPT)

	assert_eq(state.player_stats.health, 42, "血量应正确恢复")
	assert_eq(state.player_stats.max_health, 80, "最大生命应正确恢复")


func test_deserialize_statuses() -> void:
	var base_stats := CharacterStats.new()
	base_stats.max_health = 80
	base_stats.health = 80
	base_stats.max_mana = 3
	base_stats.deck = CardPile.new()
	base_stats.draw_pile = CardPile.new()
	base_stats.discard = CardPile.new()

	var payload := _make_minimal_payload()
	payload["player_stats"]["statuses"] = {"strength": 3, "weak": 2}
	var state := RunStateDeserializer.deserialize_run_state(payload, base_stats, MAP_GENERATOR_SCRIPT)

	assert_eq(state.player_stats.get_status("strength"), 3, "力量状态应正确恢复")
	assert_eq(state.player_stats.get_status("weak"), 2, "虚弱状态应正确恢复")


func test_deserialize_empty_statuses_compat() -> void:
	var base_stats := CharacterStats.new()
	base_stats.max_health = 80
	base_stats.health = 80
	base_stats.max_mana = 3
	base_stats.deck = CardPile.new()
	base_stats.draw_pile = CardPile.new()
	base_stats.discard = CardPile.new()

	var payload := _make_minimal_payload()
	# v1 存档没有 statuses 字段
	payload["player_stats"].erase("statuses")
	var state := RunStateDeserializer.deserialize_run_state(payload, base_stats, MAP_GENERATOR_SCRIPT)
	assert_not_null(state, "缺少 statuses 字段的旧存档应正常加载")


func test_deserialize_relics() -> void:
	var relics := [
		{"id": "burning_blood", "title": "燃烧之血", "on_battle_end_heal_per_kill": 2},
		{"id": "vajra", "title": "金刚杵", "on_run_start_strength": 1},
	]
	var result := RunStateDeserializer.deserialize_relics(relics)
	assert_eq(result.size(), 2, "应反序列化 2 个遗物")
	assert_eq(result[0].id, "burning_blood")
	assert_eq(result[1].id, "vajra")


func test_deserialize_relics_deduplicates() -> void:
	var relics := [
		{"id": "dup_relic", "title": "重复遗物"},
		{"id": "dup_relic", "title": "重复遗物"},
	]
	var result := RunStateDeserializer.deserialize_relics(relics)
	assert_eq(result.size(), 1, "重复遗物应被去重")


func test_deserialize_potions() -> void:
	var potions := [
		{"id": "heal_potion", "title": "治疗药水", "effect_type": 0, "value": 20},
	]
	var result := RunStateDeserializer.deserialize_potions(potions)
	assert_eq(result.size(), 1, "应反序列化 1 个药水")
	assert_eq(result[0].id, "heal_potion")
	assert_eq(result[0].value, 20)


func test_deserialize_card_basic() -> void:
	var data := {
		"id": "test_card",
		"display_name": "测试卡",
		"type": int(Card.Type.ATTACK),
		"target": int(Card.Target.SINGLE_ENEMY),
		"cost": 2,
		"keyword_exhaust": true,
	}
	var card := RunStateDeserializer.deserialize_card(data)
	assert_not_null(card, "卡牌反序列化不应为 null")
	assert_eq(card.id, "test_card")
	assert_eq(card.cost, 2)
	assert_true(card.keyword_exhaust)


func test_coerce_card_type_invalid_returns_attack() -> void:
	var result := RunStateDeserializer.coerce_card_type(999)
	assert_eq(result, Card.Type.ATTACK, "无效类型应回退到 ATTACK")


func test_coerce_node_type_invalid_returns_battle() -> void:
	var result := RunStateDeserializer.coerce_node_type(999)
	assert_eq(result, MapNodeData.NodeType.BATTLE, "无效节点类型应回退到 BATTLE")


func test_empty_map_graph_returns_null() -> void:
	var result := RunStateDeserializer.deserialize_map_graph({})
	assert_null(result, "空地图数据应返回 null")


func test_variant_to_packed_string_array() -> void:
	var result := RunStateDeserializer.variant_to_packed_string_array(["a", "b", "c"])
	assert_eq(result.size(), 3)
	assert_eq(result[0], "a")


func test_variant_to_packed_string_array_non_array() -> void:
	var result := RunStateDeserializer.variant_to_packed_string_array("not_an_array")
	assert_eq(result.size(), 0, "非数组输入应返回空数组")
