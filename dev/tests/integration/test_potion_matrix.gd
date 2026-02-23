extends GutTest

const FIXTURE := preload("res://dev/tests/integration/support/battle_test_fixture.gd")
const POTION_DIR := "res://content/custom_resources/potions"


class RelicPotionSystemHarness:
	extends RelicPotionSystem

	var fake_player: Player = null

	func _find_player() -> Player:
		return fake_player


class DummyEnemy:
	extends Node

	var damage_taken := 0

	func take_damage(amount: int) -> void:
		damage_taken += maxi(0, amount)


func test_all_potion_resources_work_in_and_out_of_battle() -> void:
	var potions := _load_potion_resources()
	assert_gt(potions.size(), 0, "药水资源不能为空")
	if potions.is_empty():
		return

	for potion in potions:
		_run_potion_case(potion)


func _run_potion_case(potion: PotionData) -> void:
	var fixture = FIXTURE.new()
	var stats: CharacterStats = fixture.create_character_stats(90, 40, 6, 3)
	var run_state := RunState.new()
	run_state.player_stats = stats
	run_state.gold = 100
	run_state.potions = [potion.duplicate(true)]

	var player: Player = fixture.create_player(stats)
	var system := RelicPotionSystemHarness.new()
	system.fake_player = player
	get_tree().root.add_child(system)

	var stack = FIXTURE.SpyEffectStack.new()
	system.effect_stack = stack
	system.bind_run_state(run_state)
	system.effect_stack = stack

	# 战斗外统一不可用，且不应消耗
	system.use_potion(0)
	assert_eq(run_state.potions.size(), 1, "战斗外不应消耗药水：%s" % potion.id)

	var enemy_a := DummyEnemy.new()
	var enemy_b := DummyEnemy.new()
	enemy_a.add_to_group("enemies")
	enemy_b.add_to_group("enemies")
	fixture.add_nodes_to_root([player, enemy_a, enemy_b])

	system.start_battle()
	system.effect_stack = stack

	var health_before := run_state.player_stats.health
	var gold_before := run_state.gold
	var block_before := run_state.player_stats.block
	var damage_before := enemy_a.damage_taken + enemy_b.damage_taken
	var enqueue_before: int = stack.enqueue_calls

	system.use_potion(0)

	assert_eq(run_state.potions.size(), 0, "战斗中应消耗药水：%s" % potion.id)
	assert_gt(stack.enqueue_calls, enqueue_before, "药水效果应通过 EffectStack 执行：%s" % potion.id)

	match potion.effect_type:
		PotionData.EffectType.HEAL:
			assert_gt(run_state.player_stats.health, health_before, "治疗药水应恢复生命：%s" % potion.id)
		PotionData.EffectType.GOLD:
			assert_gt(run_state.gold, gold_before, "金币药水应增加金币：%s" % potion.id)
		PotionData.EffectType.BLOCK:
			assert_gt(run_state.player_stats.block, block_before, "格挡药水应增加格挡：%s" % potion.id)
		PotionData.EffectType.DAMAGE_ALL_ENEMIES:
			var damage_after := enemy_a.damage_taken + enemy_b.damage_taken
			assert_gt(damage_after, damage_before, "伤害药水应命中敌人：%s" % potion.id)
		_:
			fail_test("未知药水类型：%s" % potion.id)
			return

	system.fake_player = null
	if is_instance_valid(system):
		system.queue_free()
	fixture.free_nodes([player, enemy_a, enemy_b])


func _load_potion_resources() -> Array[PotionData]:
	var potions: Array[PotionData] = []
	var dir := DirAccess.open(POTION_DIR)
	if dir == null:
		fail_test("无法打开药水目录：%s" % POTION_DIR)
		return potions

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
		var path := "%s/%s" % [POTION_DIR, file_name]
		var potion_variant: Variant = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if potion_variant is PotionData:
			potions.append(potion_variant as PotionData)
		else:
			fail_test("药水资源加载失败：%s" % path)

	return potions
