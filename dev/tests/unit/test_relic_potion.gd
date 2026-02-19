extends GutTest

const RELIC_REGISTRY_SCRIPT := preload("res://runtime/modules/relic_potion/relic_registry.gd")

class SpyEffectStack extends EffectStackEngine:
	var enqueue_calls := 0

	func enqueue_effect(
		effect_name: String,
		targets: Array[Node],
		apply_callable: Callable,
		priority: int = 50,
		effect_type: EffectType = EffectType.SPECIAL,
		source: Node = null,
		value: int = 0,
		chain_depth: int = 0
	) -> void:
		enqueue_calls += 1
		super.enqueue_effect(effect_name, targets, apply_callable, priority, effect_type, source, value, chain_depth)


class DummyEnemy:
	extends Node
	var damage_taken := 0

	func take_damage(amount: int) -> void:
		damage_taken += amount


class FakePlayer extends Player:
	func update_player() -> void:
		pass

	func update_stats() -> void:
		pass


class RelicPotionSystemForTest:
	extends RelicPotionSystem
	var fake_player: Player = null

	func _find_player() -> Player:
		return fake_player


class CustomRegistryRelic:
	extends "res://runtime/modules/relic_potion/relic_base.gd"

	var invoke_count := 0

	func on_battle_start(system: Object, _context: Dictionary) -> void:
		invoke_count += 1
		system.dispatch_relic_effect("add_gold", 17, data)


class RuntimeRelicHolder:
	extends RefCounted
	var runtime_relic: CustomRegistryRelic = null


var _system: RelicPotionSystemForTest
var _effect_stack: SpyEffectStack
var _player: Player
var _run_state: RunState


func before_all() -> void:
	gut.p("RelicPotion 测试套件初始化")


func before_each() -> void:
	RELIC_REGISTRY_SCRIPT.clear_factories()
	_system = RelicPotionSystemForTest.new()
	get_tree().root.add_child(_system)
	_effect_stack = SpyEffectStack.new()
	_system.effect_stack = _effect_stack
	_run_state = _create_run_state()
	_system.bind_run_state(_run_state)
	_player = FakePlayer.new()
	_player.stats = _run_state.player_stats
	_system.fake_player = _player


func after_each() -> void:
	RELIC_REGISTRY_SCRIPT.clear_factories()
	if _player != null and is_instance_valid(_player):
		_player.free()
	_player = null
	if _system != null and is_instance_valid(_system):
		_system.fake_player = null
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


func test_block_applied_trigger_is_emitted() -> void:
	var trigger_history: Array[int] = []
	_system.trigger_fired.connect(func(trigger_type: RelicPotionSystem.TriggerType, _context: Dictionary) -> void:
		trigger_history.append(int(trigger_type))
	)

	_system.start_battle()
	Events.player_block_applied.emit(6, "test")

	assert_true(trigger_history.has(int(RelicPotionSystem.TriggerType.ON_BLOCK_APPLIED)), "获得格挡时应触发 ON_BLOCK_APPLIED")


func test_boss_killed_trigger_is_emitted() -> void:
	var trigger_history: Array[int] = []
	_system.trigger_fired.connect(func(trigger_type: RelicPotionSystem.TriggerType, _context: Dictionary) -> void:
		trigger_history.append(int(trigger_type))
	)

	var relic := RelicData.new()
	relic.id = "boss_bonus"
	relic.title = "屠龙奖赏"
	relic.on_enemy_killed_gold = 15
	_run_state.relics = [relic]
	_run_state.gold = 100

	_system.on_boss_killed()

	assert_true(trigger_history.has(int(RelicPotionSystem.TriggerType.ON_BOSS_KILLED)), "击败 Boss 时应触发 ON_BOSS_KILLED")
	assert_eq(_run_state.gold, 115, "Boss 击杀触发应能派发生命期内的遗物收益")


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


func test_custom_relic_callback_invoked_via_registry() -> void:
	var holder := RuntimeRelicHolder.new()
	RELIC_REGISTRY_SCRIPT.register_factory(
		"registry_custom",
		func(relic_data: RelicData):
			holder.runtime_relic = CustomRegistryRelic.new(relic_data)
			return holder.runtime_relic
	)

	var relic := RelicData.new()
	relic.id = "registry_custom"
	relic.title = "注册回调遗物"
	_run_state.relics = [relic]
	_run_state.gold = 100

	_system.start_battle()

	assert_not_null(holder.runtime_relic, "应通过 RelicRegistry 创建自定义遗物回调对象")
	if holder.runtime_relic != null:
		assert_eq(holder.runtime_relic.invoke_count, 1, "自定义遗物回调应在 ON_BATTLE_START 触发")
	assert_eq(_run_state.gold, 117, "自定义遗物回调应生效并修改战斗收益")


# 测试重试上限常量存在
func test_max_battle_start_retries_constant_exists() -> void:
	# 验证 MAX_BATTLE_START_RETRIES 常量存在且为合理值
	assert_eq(RelicPotionSystem.MAX_BATTLE_START_RETRIES, 100, "MAX_BATTLE_START_RETRIES 应为 100")


func test_relic_runtime_cache_reuses_same_instance() -> void:
	# 测试遗物运行时缓存：相同 ID 的遗物应复用同一个运行时实例
	# 避免每次触发都创建新对象

	# 创建一个带状态的遗物运行时类
	RELIC_REGISTRY_SCRIPT.register_factory(
		"stateful_relic",
		func(relic_data: RelicData):
			return StatefulTestRelic.new(relic_data)
	)

	# 添加遗物
	var relic := RelicData.new()
	relic.id = "stateful_relic"
	relic.title = "有状态遗物"
	_run_state.relics = [relic]

	# 绑定 RunState 会重建缓存
	_system.bind_run_state(_run_state)

	# 第一次触发
	_system.start_battle()
	var first_runtime: Variant = _system._relic_runtimes.get("stateful_relic", null)
	assert_not_null(first_runtime, "首次触发后应有缓存")

	# 结束战斗并开始新战斗
	_system.end_battle()
	_system.start_battle()

	# 第二次触发：应复用同一个实例
	var second_runtime: Variant = _system._relic_runtimes.get("stateful_relic", null)
	assert_not_null(second_runtime, "二次触发后应有缓存")
	assert_eq(first_runtime, second_runtime, "相同 ID 应复用同一运行时实例")

	RELIC_REGISTRY_SCRIPT.clear_factories()


func test_relic_runtime_cache_duplicate_id_shares_state() -> void:
	# 测试重复 relic id 的行为：共享同一运行时实例（可能导致状态共享歧义）
	# 这是预期行为的文档化测试，开发者应避免使用重复 ID

	RELIC_REGISTRY_SCRIPT.register_factory(
		"dup_id_relic",
		func(relic_data: RelicData):
			return StatefulTestRelic.new(relic_data)
	)

	# 创建两个相同 ID 的遗物数据
	var relic1 := RelicData.new()
	relic1.id = "dup_id_relic"
	relic1.title = "重复遗物1"

	var relic2 := RelicData.new()
	relic2.id = "dup_id_relic"
	relic2.title = "重复遗物2"  # 不同的 title，但相同 ID

	_run_state.relics = [relic1, relic2]

	# 绑定 RunState 会重建缓存
	_system.bind_run_state(_run_state)

	# 缓存中应只有一个实例（因为 ID 相同）
	var cached_runtime: Variant = _system._relic_runtimes.get("dup_id_relic", null)
	assert_not_null(cached_runtime, "应有缓存")

	# 缓存大小应为 1（而不是 2）
	assert_eq(_system._relic_runtimes.size(), 1, "重复 ID 应只缓存一个实例")

	# 重要：如果两个遗物数据有不同的属性，后加载的会覆盖缓存
	# 这意味着两个遗物将共享同一个运行时实例，可能导致状态混淆
	# 建议：遗物 ID 应唯一，或在添加遗物时检查重复

	RELIC_REGISTRY_SCRIPT.clear_factories()


func test_relic_runtime_cache_clears_on_rebind() -> void:
	# 测试重新绑定 RunState 时缓存被清除

	RELIC_REGISTRY_SCRIPT.register_factory(
		"temp_relic",
		func(relic_data: RelicData):
			return StatefulTestRelic.new(relic_data)
	)

	var relic := RelicData.new()
	relic.id = "temp_relic"
	_run_state.relics = [relic]

	_system.bind_run_state(_run_state)
	assert_true(_system._relic_runtimes.has("temp_relic"), "绑定后应有缓存")

	# 创建新的 RunState 并重新绑定
	var new_run_state := _create_run_state()
	_system.bind_run_state(new_run_state)

	# 缓存应被清除（因为新的 RunState 没有这个遗物）
	assert_false(_system._relic_runtimes.has("temp_relic"), "重新绑定后旧缓存应被清除")

	RELIC_REGISTRY_SCRIPT.clear_factories()


# 带状态的测试遗物类
class StatefulTestRelic:
	extends RefCounted
	var data: RelicData
	var trigger_count := 0

	func _init(relic_data: RelicData) -> void:
		data = relic_data

	func handle_trigger(trigger_type: int, _context: Dictionary, _system: Object) -> void:
		trigger_count += 1


func test_battle_start_retry_count_increments_on_context_not_ready() -> void:
	# 测试当上下文未就绪时，重试计数器会增加
	var system := RelicPotionSystem.new()
	get_tree().root.add_child(system)

	var run_state := _create_run_state()
	system.bind_run_state(run_state)

	# effect_stack 为 null 时，_is_battle_start_context_ready() 返回 false
	system.effect_stack = null

	# 初始状态
	assert_eq(system._battle_start_retry_count, 0, "初始重试计数应为 0")

	# 设置战斗状态
	system._battle_active = true
	system._pending_battle_start_trigger = true

	# 调用重试方法
	system._deferred_try_fire_battle_start_trigger()

	# 验证重试计数增加了
	assert_eq(system._battle_start_retry_count, 1, "上下文未就绪时重试计数应增加")

	# 清理
	system.free()


func test_battle_start_gives_up_after_max_retries() -> void:
	# 测试重试次数超过上限后放弃
	var system := RelicPotionSystem.new()
	get_tree().root.add_child(system)

	var run_state := _create_run_state()
	system.bind_run_state(run_state)

	# effect_stack 为 null 时，_is_battle_start_context_ready() 返回 false
	system.effect_stack = null

	# 模拟重试计数器已经达到上限
	system._battle_start_retry_count = 100

	# 设置战斗状态
	system._battle_active = true
	system._pending_battle_start_trigger = true

	# 调用重试方法（应该放弃）
	system._deferred_try_fire_battle_start_trigger()

	# 验证已放弃触发
	assert_eq(system._pending_battle_start_trigger, false, "重试次数超限后应放弃触发")
	assert_eq(system._battle_start_retry_count, 101, "重试计数应为 101")

	# 清理
	system.free()


func test_battle_start_triggers_when_context_ready() -> void:
	# 测试上下文就绪时正常触发（使用已有的测试子类）
	# 使用 _system（RelicPotionSystemForTest），它已经设置了 fake_player

	# 设置遗物
	var relic := RelicData.new()
	relic.id = "test_relic"
	relic.on_battle_start_heal = 5
	_run_state.relics = [relic]
	_run_state.player_stats.health = 40

	# 设置战斗状态
	_system._battle_active = true
	_system._pending_battle_start_trigger = true
	_system._battle_start_retry_count = 0

	# 调用重试方法
	_system._deferred_try_fire_battle_start_trigger()

	# 验证成功触发
	assert_eq(_system._pending_battle_start_trigger, false, "成功触发后应清除待触发标志")


func test_relic_view_model_produces_tooltip_data() -> void:
	# 测试遗物 viewmodel 生成正确的 tooltip 数据（7-2 回归测试）
	var view_model_script := preload("res://runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd")
	var view_model := view_model_script.new()

	var relic := RelicData.new()
	relic.id = "test_relic_tooltip"
	relic.title = "测试遗物"
	relic.description = "测试效果描述"

	var run_state := _create_run_state()
	run_state.relics = [relic]

	var projection: Dictionary = view_model.project(run_state, "")

	assert_true(projection.has("relic_items"), "projection 应包含 relic_items")
	var relic_items: Array = projection.get("relic_items", [])
	assert_eq(relic_items.size(), 1, "应有一个遗物项")

	var item: Dictionary = relic_items[0]
	assert_eq(item.get("title", ""), "测试遗物", "遗物标题应正确")
	assert_true(item.get("tooltip_text", "").contains("测试遗物"), "tooltip 应包含遗物标题")
	assert_true(item.get("tooltip_text", "").contains("测试效果描述"), "tooltip 应包含遗物描述")


func test_relic_view_model_handles_empty_relics() -> void:
	# 测试空遗物列表的处理（7-2 回归测试）
	var view_model_script := preload("res://runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd")
	var view_model := view_model_script.new()

	var run_state := _create_run_state()
	run_state.relics = []

	var projection: Dictionary = view_model.project(run_state, "")

	assert_true(projection.has("relic_items"), "projection 应包含 relic_items")
	var relic_items: Array = projection.get("relic_items", [])
	assert_eq(relic_items.size(), 0, "无遗物时应为空数组")
