extends GutTest

const BATTLE_SCENE := preload("res://runtime/scenes/battle/battle.tscn")
const APP_SCENE := preload("res://runtime/scenes/app/app.tscn")
const ENEMY_SCENE := preload("res://runtime/scenes/enemy/enemy.tscn")
const PLAYER_SCENE := preload("res://runtime/scenes/player/player.tscn")
const ENEMY_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/enemy_registry.gd")


func before_all():
	gut.p("BattleFlow 集成测试套件初始化")


func test_events_signal_mechanism():
	# 基础测试：验证 Events 信号机制正常工作
	# 使用字典作为可变引用类型（GDScript 闭包捕获问题）
	var state := {"signal_received": false, "received_enemy": null}

	var callable := func(e: Enemy):
		state["signal_received"] = true
		state["received_enemy"] = e

	Events.enemy_died.connect(callable)

	# 创建一个 Enemy 节点用于测试
	var enemy := ENEMY_SCENE.instantiate()
	get_tree().root.add_child(enemy)
	await get_tree().process_frame

	# 直接发射信号
	Events.enemy_died.emit(enemy)

	# 验证信号被接收
	assert_true(state["signal_received"], "Events.enemy_died 信号应被接收")
	assert_eq(state["received_enemy"], enemy, "接收到的 enemy 应该是发射的那个")

	# 清理
	Events.enemy_died.disconnect(callable)
	if is_instance_valid(enemy):
		enemy.free()


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

	# 使用公开接口开始新游戏
	app.start_new_game()
	await get_tree().process_frame
	await get_tree().process_frame

	var run_state := app.get("run_state") as RunState
	var relic_system := app.get("relic_potion_system") as RelicPotionSystem
	assert_not_null(run_state, "新游戏后应有 RunState")
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

	app.start_battle_for_test("act1_crab_single")
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
	# DOT 死亡战斗链路集成测试：使用真实战斗场景验证毒效果杀死敌人
	# 完整链路：BattleContext -> BuffSystem._trigger_poison -> _handle_death -> Events.enemy_died

	# === 1. 创建战斗场景 ===
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_crab_single")  # 单敌人遭遇
	get_tree().root.add_child(battle)
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# === 2. 获取战斗中的敌人 ===
	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	assert_not_null(enemy_handler, "战斗场景应包含 EnemyHandler")
	if enemy_handler == null:
		if is_instance_valid(battle):
			battle.free()
		return

	var enemies := enemy_handler.get_children()
	assert_true(enemies.size() > 0, "应有敌人")
	var enemy: Enemy = enemies[0]

	# === 3. 修改敌人血量为低值（便于毒死）===
	enemy.stats.health = 5
	enemy.stats.max_health = 5

	# === 4. 获取 BuffSystem ===
	var battle_context: BattleContext = battle.get("_battle_context")
	assert_not_null(battle_context, "应有 BattleContext")
	if battle_context == null:
		if is_instance_valid(battle):
			battle.free()
		return

	# === 5. 给敌人施加毒状态（足以杀死）===
	battle_context.buff_system.apply_status_to_target(enemy, BuffSystem.STATUS_POISON, 5)
	assert_eq(battle_context.buff_system.get_status_stack(enemy.stats, BuffSystem.STATUS_POISON), 5, "敌人应有 5 层毒")

	# === 6. 监听 enemy_died 信号 ===
	# 使用字典作为可变引用类型（GDScript 闭包捕获问题）
	var signal_state := {"received": false}
	Events.enemy_died.connect(func(_e: Enemy):
		signal_state["received"] = true
	, CONNECT_ONE_SHOT)

	# === 7. 触发回合开始钩子（毒伤害触发）===
	var health_before := enemy.stats.health
	battle_context.buff_system._run_turn_start_hooks(enemy)
	var health_after := enemy.stats.health

	# === 8. 验证毒伤害生效 ===
	assert_eq(health_after, health_before - 5, "敌人应受到 5 点毒伤害，HP 从 %d 变为 %d" % [health_before, health_after])

	# === 9. 验证敌人血量 <= 0 ===
	assert_true(enemy.stats.health <= 0, "敌人 HP 应 <= 0，实际为 %d" % enemy.stats.health)

	# === 10. 验证敌人死亡信号 ===
	assert_true(signal_state["received"], "敌人死于毒时应发射 enemy_died 信号")

	# === 11. 验证运行时死亡链路触发移除并结束战斗（核心断言）===
	# 这里不手动 remove_enemy，必须通过 battle.gd 的 enemy_died 回调完成移除
	await get_tree().process_frame
	assert_eq(enemy_handler.get_child_count(), 0, "enemy_died 后应从 EnemyHandler 移除敌人")
	var battle_result := battle_context.phase_machine.check_battle_end()
	assert_true(battle_result.ended, "敌人死亡后战斗应结束")
	assert_eq(battle_result.result, "victory", "敌人死亡后应判定胜利")

	# === 清理 ===
	if is_instance_valid(battle):
		battle.queue_free()
		await get_tree().process_frame


func test_dot_damage_and_death_logic_via_trigger_poison():
	# 测试 DOT 伤害逻辑：验证 _trigger_poison 到信号发射的完整链路

	# === 1. 创建战斗场景 ===
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_crab_single")
	get_tree().root.add_child(battle)
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# === 2. 获取战斗中的敌人 ===
	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	assert_not_null(enemy_handler, "战斗场景应包含 EnemyHandler")
	if enemy_handler == null:
		if is_instance_valid(battle):
			battle.free()
		return

	var enemy: Enemy = enemy_handler.get_child(0)
	enemy.stats.health = 10
	enemy.stats.max_health = 10

	# === 3. 获取 BuffSystem ===
	var battle_context: BattleContext = battle.get("_battle_context")
	assert_not_null(battle_context, "应有 BattleContext")
	if battle_context == null:
		if is_instance_valid(battle):
			battle.free()
		return

	# === 4. 应用毒状态 ===
	battle_context.buff_system.apply_status_to_target(enemy, BuffSystem.STATUS_POISON, 10)
	assert_eq(battle_context.buff_system.get_status_stack(enemy.stats, BuffSystem.STATUS_POISON), 10, "应有 10 层毒")

	# === 5. 监听 enemy_died 信号 ===
	# 使用字典作为可变引用类型（GDScript 闭包捕获问题）
	var signal_state := {"received": false}
	Events.enemy_died.connect(func(_e: Enemy):
		signal_state["received"] = true
	, CONNECT_ONE_SHOT)

	# === 6. 调用 _trigger_poison（核心链路）===
	battle_context.buff_system._trigger_poison(enemy, enemy.stats)

	# === 7. 验证血量减少 ===
	assert_eq(enemy.stats.health, 0, "应受到 10 点毒伤害")

	# === 8. 验证死亡信号 ===
	assert_true(signal_state["received"], "毒伤害致死应触发 enemy_died 信号")

	# === 9. 验证毒层递减 ===
	assert_eq(battle_context.buff_system.get_status_stack(enemy.stats, BuffSystem.STATUS_POISON), 9, "毒应递减到 9")

	# === 清理 ===
	if is_instance_valid(battle):
		battle.queue_free()
		await get_tree().process_frame


func test_battle_phase_machine_empty_enemies_victory():
	# 测试战斗状态机：绑定有效玩家且空敌人列表时判定胜利

	# === 1. 创建战斗场景 ===
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_crab_single")
	get_tree().root.add_child(battle)
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# === 2. 获取战斗上下文 ===
	var battle_context: BattleContext = battle.get("_battle_context")
	assert_not_null(battle_context, "应有 BattleContext")
	if battle_context == null:
		if is_instance_valid(battle):
			battle.free()
		return

	# === 3. 获取 Player ===
	var player: Player = battle.get("player")
	assert_not_null(player, "应有 Player")

	# === 4. 移除所有敌人（模拟战斗胜利）===
	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	if enemy_handler != null:
		for child in enemy_handler.get_children():
			if child is Enemy:
				battle_context.remove_enemy(child)

	# === 5. 验证战斗结束判定 ===
	var battle_result := battle_context.phase_machine.check_battle_end()
	assert_true(battle_result.ended, "空敌人列表时战斗应结束")
	assert_eq(battle_result.result, "victory", "空敌人列表应判定胜利")

	# === 清理 ===
	if is_instance_valid(battle):
		battle.free()


func test_battle_phase_machine_with_dead_enemy():
	# 测试战斗状态机：敌人 HP <= 0 时判定胜利

	# === 1. 创建战斗场景 ===
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_crab_single")
	get_tree().root.add_child(battle)
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# === 2. 获取战斗上下文和敌人 ===
	var battle_context: BattleContext = battle.get("_battle_context")
	assert_not_null(battle_context, "应有 BattleContext")
	if battle_context == null:
		if is_instance_valid(battle):
			battle.free()
		return

	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	assert_not_null(enemy_handler, "应有 EnemyHandler")
	if enemy_handler == null:
		if is_instance_valid(battle):
			battle.free()
		return

	var enemy: Enemy = enemy_handler.get_child(0)

	# === 3. 将敌人 HP 设为 0（模拟已死亡）===
	enemy.stats.health = 0

	# === 4. 验证战斗结束判定 ===
	var battle_result := battle_context.phase_machine.check_battle_end()
	assert_true(battle_result.ended, "敌人 HP=0 时战斗应结束")
	assert_eq(battle_result.result, "victory", "敌人死亡应判定胜利")

	# === 清理 ===
	if is_instance_valid(battle):
		battle.free()


func test_handle_death_signal_for_enemies_group():
	# 测试 _handle_death 对真实 Enemy 的信号发射

	# === 1. 创建战斗场景 ===
	var battle := BATTLE_SCENE.instantiate()
	battle.set("encounter_id", "act1_crab_single")
	get_tree().root.add_child(battle)
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout

	# === 2. 获取战斗上下文和敌人 ===
	var battle_context: BattleContext = battle.get("_battle_context")
	assert_not_null(battle_context, "应有 BattleContext")
	if battle_context == null:
		if is_instance_valid(battle):
			battle.free()
		return

	var enemy_handler := battle.get_node_or_null("EnemyHandler")
	assert_not_null(enemy_handler, "应有 EnemyHandler")
	if enemy_handler == null:
		if is_instance_valid(battle):
			battle.free()
		return

	var enemy: Enemy = enemy_handler.get_child(0)

	# === 3. 验证敌人已在 enemies 组中 ===
	assert_true(enemy.is_in_group("enemies"), "Enemy 应在 enemies 组中")

	# === 4. 监听 enemy_died 信号 ===
	# 使用字典作为可变引用类型（GDScript 闭包捕获问题）
	var signal_state := {"received": false}
	Events.enemy_died.connect(func(_e: Enemy):
		signal_state["received"] = true
	, CONNECT_ONE_SHOT)

	# === 5. 调用 _handle_death ===
	battle_context.buff_system._handle_death(enemy)

	# === 6. 验证信号发射 ===
	assert_true(signal_state["received"], "真实 Enemy 应触发 enemy_died 信号")

	# === 清理 ===
	if is_instance_valid(battle):
		battle.queue_free()
		await get_tree().process_frame


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
