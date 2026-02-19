extends GutTest

const RELIC_POTION_SYSTEM_SCRIPT := preload("res://runtime/modules/relic_potion/relic_potion_system.gd")
class SpyEffectStack extends EffectStackEngine:
	var enqueue_calls := 0

	func enqueue_effect(
		effect_name: String,
		targets: Array[Node],
		apply_callable: Callable,
		priority: int = 50,
		effect_type: EffectType = EffectType.SPECIAL,
		source: Node = null,
		value: int = 0
	) -> void:
		enqueue_calls += 1
		super.enqueue_effect(effect_name, targets, apply_callable, priority, effect_type, source, value)


class DummyEnemy:
	extends Node
	var damage_taken := 0

	func take_damage(amount: int) -> void:
		damage_taken += amount


var _system: RelicPotionSystem
var _effect_stack: SpyEffectStack
var _player: Player
var _run_state: RunState


func before_all() -> void:
	gut.p("RelicPotion 测试套件初始化")


func before_each() -> void:
	_system = RELIC_POTION_SYSTEM_SCRIPT.new()
	get_tree().root.add_child(_system)
	_effect_stack = SpyEffectStack.new()
	_system.effect_stack = _effect_stack
	_run_state = _create_run_state()
	_system.bind_run_state(_run_state)
	_player = partial_double(Player).new()
	stub(_player, "update_stats").to_do_nothing()
	_player.stats = _run_state.player_stats
	if not _player.is_in_group("player"):
		_player.add_to_group("player")
	get_tree().root.add_child(_player)


func after_each() -> void:
	if _player != null and is_instance_valid(_player):
		_player.free()
	_player = null
	if _system != null and is_instance_valid(_system):
		_system.free()
	_system = null
	_effect_stack = null
	_run_state = null


func _create_run_state() -> RunState:
	var run_state := RunState.new()
	var stats := CharacterStats.new()
	stats.max_health = 80
	stats.health = 60
	stats.max_mana = 3
	stats.starting_deck = CardPile.new()
	stats.deck = CardPile.new()
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()
	run_state.player_stats = stats
	run_state.gold = 100
	return run_state


func test_trigger_type_enum_exists() -> void:
	assert_true(RelicPotionSystem.TriggerType.ON_BATTLE_START >= 0)
	assert_true(RelicPotionSystem.TriggerType.ON_BOSS_KILLED >= 0)


func test_trigger_types_defined() -> void:
	var values := [
		RelicPotionSystem.TriggerType.ON_BATTLE_START,
		RelicPotionSystem.TriggerType.ON_TURN_START,
		RelicPotionSystem.TriggerType.ON_TURN_END,
		RelicPotionSystem.TriggerType.ON_CARD_PLAYED,
		RelicPotionSystem.TriggerType.ON_ATTACK_PLAYED,
		RelicPotionSystem.TriggerType.ON_SKILL_PLAYED,
		RelicPotionSystem.TriggerType.ON_DAMAGE_TAKEN,
		RelicPotionSystem.TriggerType.ON_BLOCK_APPLIED,
		RelicPotionSystem.TriggerType.ON_ENEMY_KILLED,
		RelicPotionSystem.TriggerType.ON_RUN_START,
		RelicPotionSystem.TriggerType.ON_SHOP_ENTER,
		RelicPotionSystem.TriggerType.ON_BOSS_KILLED,
	]
	var unique := {}
	for value in values:
		unique[value] = true
	assert_eq(values.size(), 12, "应定义 12 种触发时机")
	assert_eq(unique.size(), 12, "触发时机枚举值应唯一")


func test_relic_fires_on_correct_trigger_event() -> void:
	var trigger_history: Array[int] = []
	_system.trigger_fired.connect(func(trigger_type: RelicPotionSystem.TriggerType, _context: Dictionary) -> void:
		trigger_history.append(int(trigger_type))
	)

	var relic := RelicData.new()
	relic.id = "test_relic"
	relic.title = "战斗开场恢复"
	relic.on_battle_start_heal = 5
	_run_state.relics = [relic]
	_run_state.player_stats.health = 40

	_system.start_battle()

	assert_true(trigger_history.has(int(RelicPotionSystem.TriggerType.ON_BATTLE_START)), "应触发 ON_BATTLE_START")
	assert_eq(_run_state.player_stats.health, 45, "遗物应在战斗开始恢复生命")
	assert_eq(_effect_stack.enqueue_calls, 1, "遗物效果应通过 EffectStack 派发")


func test_potion_applies_effect_via_effect_stack() -> void:
	var potion := PotionData.new()
	potion.id = "heal_potion_test"
	potion.title = "治疗药水"
	potion.effect_type = PotionData.EffectType.HEAL
	potion.value = 9
	_run_state.player_stats.health = 30
	_run_state.potions = [potion]

	_system.use_potion(0)

	assert_eq(_effect_stack.enqueue_calls, 1, "药水效果应通过 EffectStack 派发")
	assert_eq(_run_state.player_stats.health, 39, "药水应正确生效")
	assert_eq(_run_state.potions.size(), 0, "药水使用后应从背包移除")


func test_turn_start_relic_grants_block() -> void:
	var relic := RelicData.new()
	relic.id = "turn_start_block"
	relic.title = "开场护甲"
	relic.on_turn_start_block = 3
	_run_state.relics = [relic]
	_run_state.player_stats.block = 0
	_effect_stack.enqueue_calls = 0

	_system.start_battle()
	_system._on_player_turn_start()

	assert_eq(_run_state.player_stats.block, 3, "ON_TURN_START 遗物应在回合开始增加格挡")
	assert_eq(_effect_stack.enqueue_calls, 1, "ON_TURN_START 遗物应通过 EffectStack 派发")


func test_turn_end_relic_heals_player() -> void:
	var relic := RelicData.new()
	relic.id = "turn_end_heal"
	relic.title = "回合回复"
	relic.on_turn_end_heal = 4
	_run_state.relics = [relic]
	_run_state.player_stats.health = 30
	_effect_stack.enqueue_calls = 0

	_system.start_battle()
	_system._on_player_turn_end()

	assert_eq(_run_state.player_stats.health, 34, "ON_TURN_END 遗物应在回合结束恢复生命")
	assert_eq(_effect_stack.enqueue_calls, 1, "ON_TURN_END 遗物应通过 EffectStack 派发")


func test_shop_enter_trigger_is_emitted() -> void:
	var trigger_history: Array[int] = []
	_system.trigger_fired.connect(func(trigger_type: RelicPotionSystem.TriggerType, _context: Dictionary) -> void:
		trigger_history.append(int(trigger_type))
	)

	var relic := RelicData.new()
	relic.id = "shop_discount"
	relic.title = "店铺折扣"
	relic.shop_discount_percent = 20
	_run_state.relics = [relic]

	_system.on_shop_enter()

	assert_true(trigger_history.has(int(RelicPotionSystem.TriggerType.ON_SHOP_ENTER)), "进入商店应触发 ON_SHOP_ENTER")


func test_run_start_relic_applies_once() -> void:
	var relic := RelicData.new()
	relic.id = "run_start_bonus"
	relic.title = "开局奖励"
	relic.on_run_start_gold = 25
	_run_state.relics = [relic]
	_run_state.gold = 100
	_run_state.floor = 0
	_run_state.map_visited_node_ids = PackedStringArray()
	_run_state.run_start_relics_applied = false

	_system.bind_run_state(_run_state)
	assert_eq(_run_state.gold, 125, "首次绑定应触发 ON_RUN_START 并加金币")
	assert_true(_run_state.run_start_relics_applied, "应记录开局触发已执行")

	_system.bind_run_state(_run_state)
	assert_eq(_run_state.gold, 125, "重复绑定不应重复触发 ON_RUN_START")


func test_damage_all_enemies_potion_hits_all_targets() -> void:
	var enemy_a := DummyEnemy.new()
	var enemy_b := DummyEnemy.new()
	enemy_a.add_to_group("enemies")
	enemy_b.add_to_group("enemies")
	get_tree().root.add_child(enemy_a)
	get_tree().root.add_child(enemy_b)

	var potion := PotionData.new()
	potion.id = "storm_bomb"
	potion.title = "爆裂药水"
	potion.effect_type = PotionData.EffectType.DAMAGE_ALL_ENEMIES
	potion.value = 10
	_run_state.potions = [potion]

	_system.use_potion(0)

	assert_eq(enemy_a.damage_taken, 10, "敌人 A 应受到 10 点伤害")
	assert_eq(enemy_b.damage_taken, 10, "敌人 B 应受到 10 点伤害")
	assert_eq(_run_state.potions.size(), 0, "药水使用后应移除")

	if is_instance_valid(enemy_a):
		enemy_a.free()
	if is_instance_valid(enemy_b):
		enemy_b.free()
