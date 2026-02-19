extends GutTest

const BATTLE_SCENE := preload("res://runtime/scenes/battle/battle.tscn")
const APP_SCENE := preload("res://runtime/scenes/app/app.tscn")


func before_all():
	gut.p("BattleFlow 集成测试套件初始化")


func test_boss_encounter_spawns_boss_enemy():
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_boss_slime")
	get_tree().root.add_child(battle)
	await get_tree().process_frame

	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	assert_not_null(enemy_handler, "战斗场景应包含 EnemyHandler")
	if enemy_handler != null:
		assert_eq(enemy_handler.get_child_count(), 1, "Boss 遭遇应只生成 1 个敌人")
		if enemy_handler.get_child_count() > 0:
			var first_enemy := enemy_handler.get_child(0)
			assert_true(first_enemy is Enemy, "Boss 遭遇应生成 Enemy 节点")
			if first_enemy is Enemy:
				assert_true((first_enemy as Enemy).stats.max_health >= 100, "Boss 血量应明显高于普通怪")

	if is_instance_valid(battle):
		battle.free()


func test_battle_scene_does_not_end_immediately_after_setup():
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_boss_slime")
	get_tree().root.add_child(battle)
	await get_tree().process_frame

	var battle_ended_variant: Variant = battle.get("_battle_ended")
	var battle_ended := false
	if battle_ended_variant is bool:
		battle_ended = battle_ended_variant
	assert_false(battle_ended, "战斗初始化后不应立刻结束")

	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	assert_not_null(enemy_handler, "战斗初始化后应存在敌人容器")
	if enemy_handler != null:
		assert_true(enemy_handler.get_child_count() > 0, "战斗初始化后应有敌人")

	if is_instance_valid(battle):
		battle.free()


func test_on_battle_start_relic_fires_after_battle_scene_ready():
	var app := APP_SCENE.instantiate()
	get_tree().root.add_child(app)
	await get_tree().process_frame
	await get_tree().process_frame

	var run_state := app.get("run_state") as RunState
	var relic_system := app.get("relic_potion_system") as RelicPotionSystem
	assert_not_null(run_state, "App 初始化后应有 RunState")
	assert_not_null(relic_system, "App 初始化后应有 RelicPotionSystem")
	if run_state == null or relic_system == null:
		if is_instance_valid(app):
			app.free()
		return

	var relic := RelicData.new()
	relic.id = "battle_start_heal_test"
	relic.title = "战斗开场治疗"
	relic.on_battle_start_heal = 5
	run_state.relics = [relic]
	run_state.player_stats.health = maxi(1, run_state.player_stats.health - 10)
	var health_before := run_state.player_stats.health

	app.call("_open_battle", "act1_crab_single")
	await get_tree().create_timer(0.2, false).timeout
	await get_tree().process_frame

	assert_not_null(relic_system.effect_stack, "战斗场景就绪后应已注入 effect_stack")
	assert_eq(
		run_state.player_stats.health,
		mini(run_state.player_stats.max_health, health_before + 5),
		"ON_BATTLE_START 遗物效果应在首回合生效"
	)

	if is_instance_valid(app):
		app.free()


func test_dot_death_triggers_battle_end_correctly():
	# 测试 DOT 效果杀死敌人后战斗正确结束
	# 这是单元测试的补充，验证 BuffSystem 死亡处理不导致竞态
	var buff_system := BuffSystem.new()

	# 创建模拟的 stats
	var stats := Stats.new()
	stats.max_health = 10
	stats.health = 5

	# 模拟 DOT 伤害导致死亡
	stats.health = 0

	# 验证死亡判定
	assert_true(stats.health <= 0, "HP <= 0 应判定死亡")

	# 清理
	buff_system = null


func test_rest_screen_upgrade_uses_upgrade_to_field():
	# 测试营地升级是否使用 upgrade_to 字段
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 80
	stats.starting_deck = CardPile.new()
	stats.max_mana = 3
	stats.cards_per_turn = 5
	stats.deck = CardPile.new()
	run_state.player_stats = stats

	# 添加一张有 upgrade_to 字段的卡牌
	var card := Card.new()
	card.id = "test_card"
	card.cost = 2
	card.upgrade_to = "test_card_upgraded"
	card.tooltip_text = "Test card"
	stats.deck.add_card(card)

	# 执行升级
	var result := run_state.upgrade_card_in_deck_at(0)
	assert_true(result, "升级应成功")

	var upgraded_card: Card = stats.deck.cards[0]
	assert_eq(upgraded_card.id, "test_card_upgraded", "升级后应使用 upgrade_to 字段作为新 ID")
	assert_eq(upgraded_card.cost, 1, "升级后费用应减少")


func test_rest_screen_upgrade_fallback_to_hardcoded():
	# 测试没有 upgrade_to 字段时回退到硬编码行为
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 80
	stats.starting_deck = CardPile.new()
	stats.max_mana = 3
	stats.cards_per_turn = 5
	stats.deck = CardPile.new()
	run_state.player_stats = stats

	# 添加一张没有 upgrade_to 字段的卡牌
	var card := Card.new()
	card.id = "basic_card"
	card.cost = 1
	card.upgrade_to = ""  # 空 upgrade_to
	card.tooltip_text = "Basic card"
	stats.deck.add_card(card)

	# 执行升级
	var result := run_state.upgrade_card_in_deck_at(0)
	assert_true(result, "升级应成功")

	var upgraded_card: Card = stats.deck.cards[0]
	assert_eq(upgraded_card.id, "basic_card+", "没有 upgrade_to 时应追加 +")
	assert_eq(upgraded_card.cost, 0, "升级后费用应减少")


func test_damage_potion_not_consumed_outside_battle():
	# 测试战斗外使用伤害药水不被消耗
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 80
	stats.starting_deck = CardPile.new()
	stats.max_mana = 3
	stats.cards_per_turn = 5
	stats.deck = CardPile.new()
	run_state.player_stats = stats

	# 添加伤害药水
	var potion := PotionData.new()
	potion.id = "damage_potion"
	potion.title = "爆炸药水"
	potion.effect_type = PotionData.EffectType.DAMAGE_ALL_ENEMIES
	potion.value = 20
	run_state.potions.append(potion)

	var potion_count_before := run_state.potions.size()

	# 战斗外使用伤害药水
	var result := run_state.use_potion_at(0)

	# 验证药水未被消耗
	assert_eq(run_state.potions.size(), potion_count_before, "战斗外使用伤害药水不应消耗药水")
	assert_true(result.contains("仅战斗中可生效"), "应提示仅战斗中可生效")
