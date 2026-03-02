extends GutTest

const FIXTURE := preload("res://dev/tests/integration/support/battle_test_fixture.gd")
const CARD_SOURCE_PATH := "res://runtime/modules/content_pipeline/sources/cards/warrior_cards.json"
const CARD_RESOURCE_DIR := "res://content/characters/warrior/cards/generated"


func test_all_generated_cards_execute_effects_with_expected_signals() -> void:
	var card_defs := _load_card_definitions()
	assert_gt(card_defs.size(), 0, "卡牌配置不能为空")
	if card_defs.is_empty():
		return

	for card_def_variant in card_defs:
		if not (card_def_variant is Dictionary):
			fail_test("卡牌定义必须是 Dictionary")
			return
		var card_def: Dictionary = card_def_variant as Dictionary
		_run_card_case(card_def)


func _run_card_case(card_def: Dictionary) -> void:
	var fixture = FIXTURE.new()
	var card_id := str(card_def.get("id", ""))
	var card_path := "%s/%s.tres" % [CARD_RESOURCE_DIR, card_id]
	assert_true(ResourceLoader.exists(card_path), "卡牌资源应存在：%s" % card_id)
	if not ResourceLoader.exists(card_path):
		return

	var card_variant: Variant = ResourceLoader.load(card_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	assert_true(card_variant is Card, "卡牌资源应可加载为 Card：%s" % card_id)
	if not (card_variant is Card):
		return
	var card: Card = card_variant as Card

	var player_stats: CharacterStats = fixture.create_character_stats(90, 60, 10, 10)
	var enemy_stats_a: EnemyStats = fixture.create_enemy_stats(120, 120)
	var enemy_stats_b: EnemyStats = fixture.create_enemy_stats(120, 120)
	var player: Player = fixture.create_player(player_stats)
	var enemy_a: Enemy = fixture.create_enemy(enemy_stats_a)
	var enemy_b: Enemy = fixture.create_enemy(enemy_stats_b)
	var nodes: Array[Node] = [player, enemy_a, enemy_b]
	fixture.add_nodes_to_root(nodes)

	var stack = FIXTURE.SpyEffectStack.new()
	var context = FIXTURE.TestBattleContext.new(player, [enemy_a, enemy_b], stack, player_stats)
	var before := _snapshot_metrics(fixture, player, [enemy_a, enemy_b], context, stack)

	assert_true(card.can_play(player_stats, context), "卡牌应可播放：%s" % card_id)
	card.play([enemy_a], player_stats, context)

	var after := _snapshot_metrics(fixture, player, [enemy_a, enemy_b], context, stack)
	_assert_effects(card, card_def, before, after)

	context.unbind_battle_context()
	SFXPlayer.stop()
	fixture.free_nodes(nodes)


func _snapshot_metrics(
	fixture,
	player: Player,
	enemies: Array[Enemy],
	context,
	stack
) -> Dictionary:
	var enemy_health_total := 0
	var enemy_status_total := 0
	for enemy in enemies:
		if enemy == null or enemy.stats == null:
			continue
		enemy_health_total += enemy.stats.health
		enemy_status_total += fixture.status_total(enemy.stats)

	return {
		"player_health": player.stats.health if player != null and player.stats != null else 0,
		"player_block": player.stats.block if player != null and player.stats != null else 0,
		"player_mana": player.stats.mana if player != null and player.stats != null else 0,
		"player_status_total": fixture.status_total(player.stats) if player != null and player.stats != null else 0,
		"enemy_health_total": enemy_health_total,
		"enemy_status_total": enemy_status_total,
		"draw_total": _sum_int_array(context.draw_calls),
		"enqueue_calls": stack.enqueue_calls,
	}


func _assert_effects(card: Card, card_def: Dictionary, before: Dictionary, after: Dictionary) -> void:
	var card_id := str(card_def.get("id", ""))
	var effects_variant: Variant = card_def.get("effects", [])
	assert_true(effects_variant is Array, "effects 必须是数组：%s" % card_id)
	if not (effects_variant is Array):
		return
	var effects: Array = effects_variant

	for effect_variant in effects:
		if not (effect_variant is Dictionary):
			fail_test("effect 必须是 Dictionary：%s" % card_id)
			return
		var effect: Dictionary = effect_variant as Dictionary
		var op := str(effect.get("op", ""))
		match op:
			"damage", "conditional_damage", "strength_multiplier_damage":
				assert_lt(
					int(after.get("enemy_health_total", 0)),
					int(before.get("enemy_health_total", 0)),
					"伤害效果应生效：%s:%s" % [card_id, op]
				)
			"block", "missing_hp_block":
				assert_gt(
					int(after.get("player_block", 0)),
					int(before.get("player_block", 0)),
					"格挡效果应生效：%s:%s" % [card_id, op]
				)
			"apply_status":
				var before_status := int(before.get("player_status_total", 0)) + int(before.get("enemy_status_total", 0))
				var after_status := int(after.get("player_status_total", 0)) + int(after.get("enemy_status_total", 0))
				assert_gt(after_status, before_status, "状态效果应生效：%s:%s" % [card_id, op])
			"draw":
				assert_gt(
					int(after.get("draw_total", 0)),
					int(before.get("draw_total", 0)),
					"抽牌效果应生效：%s:%s" % [card_id, op]
				)
			"gain_energy":
				var mana_before := int(before.get("player_mana", 0))
				var spent := mana_before if card.keyword_x_cost else maxi(card.cost, 0)
				var baseline_after_spend := maxi(0, mana_before - spent)
				assert_gt(
					int(after.get("player_mana", 0)),
					baseline_after_spend,
					"回能效果应生效：%s:%s" % [card_id, op]
				)
			"lose_hp":
				assert_lt(
					int(after.get("player_health", 0)),
					int(before.get("player_health", 0)),
					"自损效果应生效：%s:%s" % [card_id, op]
				)
			"damage_and_draw":
				assert_lt(
					int(after.get("enemy_health_total", 0)),
					int(before.get("enemy_health_total", 0)),
					"伤害部分应生效：%s:%s" % [card_id, op]
				)
				assert_gt(
					int(after.get("draw_total", 0)),
					int(before.get("draw_total", 0)),
					"抽牌部分应生效：%s:%s" % [card_id, op]
				)
			"strength_and_damage_multiplier":
				assert_gt(
					int(after.get("player_status_total", 0)),
					int(before.get("player_status_total", 0)),
					"力量叠加应生效：%s:%s" % [card_id, op]
				)
			_:
				fail_test("未知效果操作符：%s:%s" % [card_id, op])
				return

	if _effects_expect_queue(effects):
		assert_gt(
			int(after.get("enqueue_calls", 0)),
			int(before.get("enqueue_calls", 0)),
			"卡牌效果应通过 EffectStack 入队：%s" % card_id
		)


func _load_card_definitions() -> Array:
	var file := FileAccess.open(CARD_SOURCE_PATH, FileAccess.READ)
	if file == null:
		fail_test("无法打开卡牌源数据：%s" % CARD_SOURCE_PATH)
		return []
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		fail_test("卡牌源数据不是字典：%s" % CARD_SOURCE_PATH)
		return []
	var root: Dictionary = parsed as Dictionary
	var cards_variant: Variant = root.get("cards", [])
	if not (cards_variant is Array):
		fail_test("卡牌源数据 cards 字段不是数组")
		return []
	var cards: Array = cards_variant
	cards.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	return cards


func _sum_int_array(values: Array[int]) -> int:
	var total := 0
	for value in values:
		total += value
	return total


func _effects_expect_queue(effects: Array) -> bool:
	for effect_variant in effects:
		if not (effect_variant is Dictionary):
			continue
		var effect: Dictionary = effect_variant as Dictionary
		var op := str(effect.get("op", ""))
		match op:
			"damage", "conditional_damage", "strength_multiplier_damage", "block", "missing_hp_block", "draw", "gain_energy", "damage_and_draw":
				return true
			_:
				continue
	return false
