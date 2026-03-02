extends GutTest

const FIXTURE := preload("res://dev/tests/integration/support/battle_test_fixture.gd")
const BATTLE_SESSION_PORT_SCRIPT := preload("res://runtime/modules/relic_potion/contracts/battle_session_port.gd")
const RELIC_DIR := "res://content/custom_resources/relics"


class RelicPotionSystemHarness:
	extends RelicPotionSystem

	var fake_player: Player = null

	func _find_player() -> Player:
		return fake_player


func test_all_relic_resources_apply_configured_effects() -> void:
	var relics := _load_relic_resources()
	assert_gt(relics.size(), 0, "遗物资源不能为空")
	if relics.is_empty():
		return

	for relic in relics:
		_run_relic_case(relic)


func _run_relic_case(relic: RelicData) -> void:
	var fixture = FIXTURE.new()
	var card_attack := Card.new()
	card_attack.id = "matrix_attack"
	card_attack.type = Card.Type.ATTACK
	card_attack.cost = 1

	var card_skill := Card.new()
	card_skill.id = "matrix_skill"
	card_skill.type = Card.Type.SKILL
	card_skill.cost = 1

	var stats: CharacterStats = fixture.create_character_stats(90, 55, 6, 3)
	var run_state := RunState.new()
	run_state.player_stats = stats
	run_state.gold = 100
	run_state.floor = 0
	run_state.map_visited_node_ids = PackedStringArray()
	run_state.relics = [relic.duplicate(true)]

	var player: Player = fixture.create_player(stats)
	var enemy: Enemy = fixture.create_enemy(fixture.create_enemy_stats(80, 80))
	var nodes: Array[Node] = [player, enemy]
	fixture.add_nodes_to_root(nodes)

	var stack = FIXTURE.SpyEffectStack.new()
	var context = FIXTURE.TestBattleContext.new(player, [enemy], stack, stats)
	var system := RelicPotionSystemHarness.new()
	system.fake_player = player
	var logs: Array[String] = []
	system.log_updated.connect(func(text: String) -> void:
		logs.append(text)
	)
	get_tree().root.add_child(system)

	var gold_before_bind := run_state.gold
	var max_hp_before_bind := run_state.player_stats.max_health
	var strength_before_bind := run_state.player_stats.get_status("strength")
	system.bind_run_state(run_state)

	if relic.on_run_start_gold > 0:
		assert_eq(
			run_state.gold,
			gold_before_bind + relic.on_run_start_gold,
			"开局金币应生效：%s" % relic.id
		)
	if relic.on_run_start_max_health > 0:
		assert_eq(
			run_state.player_stats.max_health,
			max_hp_before_bind + relic.on_run_start_max_health,
			"开局最大生命应生效：%s" % relic.id
		)
	if relic.on_run_start_strength > 0:
		assert_eq(
			run_state.player_stats.get_status("strength"),
			strength_before_bind + relic.on_run_start_strength,
			"开局力量应生效：%s" % relic.id
		)

	var session_port = BATTLE_SESSION_PORT_SCRIPT.new(
		stack,
		context,
		func() -> Player:
			return player,
		func() -> Array[Node]:
			return [enemy]
	)
	system.on_battle_session_bound(session_port)

	if relic.on_battle_start_heal > 0:
		run_state.player_stats.health = 40
		var health_before := run_state.player_stats.health
		system.fire_trigger(RelicPotionSystem.TriggerType.ON_BATTLE_START, {})
		assert_gt(run_state.player_stats.health, health_before, "战斗开始治疗应生效：%s" % relic.id)

	if relic.on_turn_start_block > 0 or relic.on_turn_start_energy > 0 or relic.on_turn_start_damage > 0:
		run_state.player_stats.block = 0
		run_state.player_stats.mana = 0
		run_state.player_stats.health = 50
		var mana_before := run_state.player_stats.mana
		var health_before_turn_start := run_state.player_stats.health
		system._on_player_turn_start()
		if relic.on_turn_start_block > 0:
			assert_gt(run_state.player_stats.block, 0, "回合开始格挡应生效：%s" % relic.id)
		if relic.on_turn_start_energy > 0:
			assert_gt(run_state.player_stats.mana, mana_before, "回合开始能量应生效：%s" % relic.id)
		if relic.on_turn_start_damage > 0:
			assert_lt(run_state.player_stats.health, health_before_turn_start, "回合开始自伤应生效：%s" % relic.id)

	if relic.on_turn_end_heal > 0:
		run_state.player_stats.health = 35
		var health_before_turn_end := run_state.player_stats.health
		system._on_player_turn_end()
		assert_gt(run_state.player_stats.health, health_before_turn_end, "回合结束治疗应生效：%s" % relic.id)

	if relic.on_card_played_gold > 0:
		run_state.gold = 100
		var target_triggers := maxi(1, relic.card_play_interval)
		for i in range(target_triggers):
			system._on_card_played(card_attack)
		assert_gt(run_state.gold, 100, "出牌金币应生效：%s" % relic.id)

	if relic.on_player_hit_block > 0:
		run_state.player_stats.block = 0
		system._on_player_hit()
		assert_gt(run_state.player_stats.block, 0, "受击得格挡应生效：%s" % relic.id)

	if relic.on_enemy_killed_gold > 0 or relic.on_enemy_killed_strength > 0 or relic.on_enemy_killed_damage > 0 or relic.on_enemy_killed_draw > 0:
		run_state.gold = 100
		run_state.player_stats.health = 55
		var strength_before_kill := run_state.player_stats.get_status("strength")
		var health_before_kill := run_state.player_stats.health
		var draw_before_kill := _sum_int_array(context.draw_calls)
		system._on_enemy_died(enemy)
		if relic.on_enemy_killed_gold > 0:
			assert_gt(run_state.gold, 100, "击杀金币应生效：%s" % relic.id)
		if relic.on_enemy_killed_strength > 0:
			assert_gt(run_state.player_stats.get_status("strength"), strength_before_kill, "击杀力量应生效：%s" % relic.id)
		if relic.on_enemy_killed_damage > 0:
			assert_lt(run_state.player_stats.health, health_before_kill, "击杀自伤应生效：%s" % relic.id)
		if relic.on_enemy_killed_draw > 0:
			assert_gt(_sum_int_array(context.draw_calls), draw_before_kill, "击杀抽牌应生效：%s" % relic.id)

	if relic.on_attack_played_strength > 0:
		var strength_before_attack := run_state.player_stats.get_status("strength")
		system._on_card_played(card_attack)
		assert_gt(run_state.player_stats.get_status("strength"), strength_before_attack, "攻击牌触发力量应生效：%s" % relic.id)
		if relic.attack_play_strength_max > 0:
			for i in range(relic.attack_play_strength_max + 3):
				system._on_card_played(card_attack)
			var trigger_count := system.get_relic_trigger_count(relic.id, "attack_played")
			assert_true(
				trigger_count <= relic.attack_play_strength_max,
				"攻击牌触发次数不应超过上限：%s" % relic.id
			)

	if relic.shop_discount_percent > 0:
		var logs_before_shop := logs.size()
		system.on_shop_enter()
		assert_gt(logs.size(), logs_before_shop, "商店折扣日志应存在：%s" % relic.id)

	if relic.on_battle_end_heal_per_kill > 0:
		run_state.player_stats.health = 35
		system._battle_active = true
		system._enemies_killed_in_battle = 2
		var health_before_end := run_state.player_stats.health
		system.end_battle()
		assert_gt(run_state.player_stats.health, health_before_end, "战斗结束按击杀治疗应生效：%s" % relic.id)

	if _relic_has_any_active_effect(relic):
		assert_gt(logs.size(), 0, "激活型遗物应产生触发日志：%s" % relic.id)

	context.unbind_battle_context()
	system.end_battle()
	system.fake_player = null
	if is_instance_valid(system):
		if system.get_parent() != null:
			system.get_parent().remove_child(system)
		system.free()
	SFXPlayer.stop()
	fixture.free_nodes(nodes)


func _load_relic_resources() -> Array[RelicData]:
	var relics: Array[RelicData] = []
	var dir := DirAccess.open(RELIC_DIR)
	if dir == null:
		fail_test("无法打开遗物目录：%s" % RELIC_DIR)
		return relics

	var files := PackedStringArray()
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if not file_name.ends_with(".tres"):
			continue
		files.append(file_name)
	dir.list_dir_end()
	files.sort()

	for file_name in files:
		var path := "%s/%s" % [RELIC_DIR, file_name]
		var relic_variant: Variant = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if relic_variant is RelicData:
			relics.append(relic_variant as RelicData)
		else:
			fail_test("遗物资源加载失败：%s" % path)

	return relics


func _relic_has_any_active_effect(relic: RelicData) -> bool:
	return relic.on_battle_start_heal > 0 \
		or relic.on_card_played_gold > 0 \
		or relic.on_player_hit_block > 0 \
		or relic.on_enemy_killed_gold > 0 \
		or relic.on_turn_start_block > 0 \
		or relic.on_turn_end_heal > 0 \
		or relic.shop_discount_percent > 0 \
		or relic.on_run_start_gold > 0 \
		or relic.on_run_start_max_health > 0 \
		or relic.on_turn_start_energy > 0 \
		or relic.on_turn_start_damage > 0 \
		or relic.on_enemy_killed_strength > 0 \
		or relic.on_enemy_killed_damage > 0 \
		or relic.on_enemy_killed_draw > 0 \
		or relic.on_battle_end_heal_per_kill > 0 \
		or relic.on_attack_played_strength > 0 \
		or relic.on_run_start_strength > 0


func _sum_int_array(values: Array[int]) -> int:
	var total := 0
	for value in values:
		total += value
	return total
