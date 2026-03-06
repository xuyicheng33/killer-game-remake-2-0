extends GutTest

const BATTLE_CONTEXT_SCRIPT := preload("res://runtime/modules/battle_loop/battle_context.gd")
const CRAB_ATTACK_ACTION_SCRIPT := preload("res://content/enemies/crab/crab_attack_action.gd")
const CRAB_BLOCK_ACTION_SCRIPT := preload("res://content/enemies/crab/crab_block_action.gd")
const BAT_ATTACK_ACTION_SCRIPT := preload("res://content/enemies/bat/bat_attack_action.gd")
const BAT_BLOCK_ACTION_SCRIPT := preload("res://content/enemies/bat/bat_block_action.gd")
const VIPER_ATTACK_ACTION_SCRIPT := preload("res://content/enemies/viper/viper_attack_action.gd")
const VIPER_POISON_ACTION_SCRIPT := preload("res://content/enemies/viper/viper_poison_action.gd")


class DummyEnemy:
	extends Enemy

	func set_enemy_stats(value: EnemyStats) -> void:
		stats = value

	func take_damage(damage: int) -> void:
		if stats == null:
			return
		stats.take_damage(damage)


class DummyPlayer:
	extends Player

	func set_character_stats(value: CharacterStats) -> void:
		stats = value

	func take_damage(damage: int) -> void:
		if stats == null:
			return
		stats.take_damage(damage)


class FixedSourceBuffSystem:
	extends BuffSystem

	var forced_source: Node = null

	func resolve_damage_source(_target: Node) -> Node:
		return forced_source


func _create_enemy(max_health: int = 40) -> DummyEnemy:
	var enemy := DummyEnemy.new()
	var stats := EnemyStats.new()
	stats.max_health = max_health
	stats.health = max_health
	enemy.stats = stats
	return enemy


func _create_player(max_health: int = 50) -> DummyPlayer:
	var player := DummyPlayer.new()
	var stats := CharacterStats.new()
	stats.max_health = max_health
	stats.health = max_health
	player.stats = stats
	return player


func test_enemy_action_uses_battle_context() -> void:
	var action := CRAB_ATTACK_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy()
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()
	var buff_system := FixedSourceBuffSystem.new()
	buff_system.forced_source = enemy
	context.buff_system = buff_system

	enemy.stats.add_status(BuffSystem.STATUS_STRENGTH, 2)
	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.damage = 8

	action.perform_action()
	await get_tree().create_timer(0.5, false).timeout

	assert_eq(player.stats.health, 40, "应使用 BattleContext 计算伤害（8 + 力量2）")

	if is_instance_valid(action):
		action.free()
	enemy.free()
	player.free()


func test_enemy_block_action_applies_block() -> void:
	var action := CRAB_BLOCK_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy()
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()

	enemy.stats.add_status(BuffSystem.STATUS_DEXTERITY, 2)
	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.block = 6

	action.perform_action()
	assert_eq(enemy.stats.block, 8, "敌人格挡应通过 BattleContext 生效（6 + 敏捷2）")

	if is_instance_valid(action):
		action.free()
	enemy.free()
	player.free()


func test_enemy_attack_respects_weak_vulnerable() -> void:
	var action := CRAB_ATTACK_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy()
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()
	var buff_system := FixedSourceBuffSystem.new()
	buff_system.forced_source = enemy
	context.buff_system = buff_system

	enemy.stats.add_status(BuffSystem.STATUS_WEAK, 1)
	player.stats.add_status(BuffSystem.STATUS_VULNERABLE, 1)

	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.damage = 8

	action.perform_action()
	await get_tree().create_timer(0.5, false).timeout

	assert_eq(player.stats.health, 41, "虚弱与易伤应修正敌方伤害（8 -> 9）")

	if is_instance_valid(action):
		action.free()
	enemy.free()
	player.free()


func test_bat_attack_deals_damage() -> void:
	var action := BAT_ATTACK_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy(12)
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()
	var buff_system := FixedSourceBuffSystem.new()
	buff_system.forced_source = enemy
	context.buff_system = buff_system

	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.damage = 4

	action.perform_action()
	await get_tree().create_timer(1.5, false).timeout

	assert_eq(player.stats.health, 46, "蝙蝠应造成 4 点伤害")

	if is_instance_valid(action):
		action.free()
	enemy.free()
	player.free()


func test_bat_block_grants_block() -> void:
	var action := BAT_BLOCK_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy(12)
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()

	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.block = 4

	action.perform_action()

	assert_eq(enemy.stats.block, 4, "蝙蝠格挡应生效")

	if is_instance_valid(action):
		action.free()
	enemy.free()
	player.free()


func test_viper_attack_deals_damage() -> void:
	var action := VIPER_ATTACK_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy(30)
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()
	var buff_system := FixedSourceBuffSystem.new()
	buff_system.forced_source = enemy
	context.buff_system = buff_system

	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.damage = 6

	action.perform_action()
	await get_tree().create_timer(1.0, false).timeout

	assert_eq(player.stats.health, 44, "毒蛇应造成 6 点伤害")

	if is_instance_valid(action):
		action.free()
	enemy.free()
	player.free()


func test_viper_poison_applies_poison_and_damage() -> void:
	var action := VIPER_POISON_ACTION_SCRIPT.new()
	get_tree().root.add_child(action)

	var enemy := _create_enemy(30)
	var player := _create_player()
	var context := BATTLE_CONTEXT_SCRIPT.new()
	var buff_system := FixedSourceBuffSystem.new()
	buff_system.forced_source = enemy
	context.buff_system = buff_system

	action.enemy = enemy
	action.target = player
	action.battle_context = context
	action.poison_stacks = 2
	action.chip_damage = 2

	action.perform_action()
	await get_tree().create_timer(1.0, false).timeout

	assert_lt(player.stats.health, 50, "毒蛇毒动作应造成伤害")
	assert_gt(player.stats.get_status("poison"), 0, "毒蛇应施加毒状态")
