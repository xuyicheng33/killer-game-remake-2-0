class_name RelicPotionSystem
extends Node

const RELIC_REGISTRY_SCRIPT := preload("res://runtime/modules/relic_potion/relic_registry.gd")
const BATTLE_SESSION_PORT_SCRIPT := preload("res://runtime/modules/relic_potion/contracts/battle_session_port.gd")
const RELIC_RUNTIME_CACHE_SCRIPT := preload("res://runtime/modules/relic_potion/relic_runtime_cache.gd")
const RELIC_EFFECT_EXECUTOR_SCRIPT := preload("res://runtime/modules/relic_potion/relic_effect_executor.gd")
const POTION_USE_SERVICE_SCRIPT := preload("res://runtime/modules/relic_potion/potion_use_service.gd")

enum TriggerType {
	ON_BATTLE_START,
	ON_BATTLE_END,
	ON_TURN_START,
	ON_TURN_END,
	ON_CARD_PLAYED,
	ON_ATTACK_PLAYED,
	ON_SKILL_PLAYED,
	ON_DAMAGE_TAKEN,
	ON_BLOCK_APPLIED,
	ON_ENEMY_KILLED,
	ON_RUN_START,
	ON_SHOP_ENTER,
	ON_BOSS_KILLED,
}

signal log_updated(text: String)
signal trigger_fired(trigger_type: TriggerType, context: Dictionary)
signal battle_state_changed(active: bool)

var run_state: RunState
var effect_stack: EffectStackEngine = null
var _battle_active := false
var _pending_battle_start_trigger := false
var _cards_played_in_battle := 0
var _enemies_killed_in_battle := 0
var _battle_start_retry_count := 0
var _battle_context: BattleContext = null
var _battle_session_port = null
var _relic_trigger_counts: Dictionary = {}
var _relic_runtimes: Dictionary:
	get:
		if _runtime_cache == null:
			return {}
		return _runtime_cache.data()
var _runtime_cache = null
var _effect_executor = null
var _potion_use_service = null
const MAX_BATTLE_START_RETRIES := 100


func _ready() -> void:
	_init_services()
	_connect_signals()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)
	if not Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.connect(_on_player_hit)
	if not Events.player_block_applied.is_connected(_on_player_block_applied):
		Events.player_block_applied.connect(_on_player_block_applied)
	if not Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.connect(_on_enemy_died)
	if not Events.player_hand_discarded.is_connected(_on_player_turn_end):
		Events.player_hand_discarded.connect(_on_player_turn_end)
	if not Events.player_hand_drawn.is_connected(_on_player_turn_start):
		Events.player_hand_drawn.connect(_on_player_turn_start)


func _disconnect_signals() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)
	if Events.player_block_applied.is_connected(_on_player_block_applied):
		Events.player_block_applied.disconnect(_on_player_block_applied)
	if Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.disconnect(_on_enemy_died)
	if Events.player_hand_discarded.is_connected(_on_player_turn_end):
		Events.player_hand_discarded.disconnect(_on_player_turn_end)
	if Events.player_hand_drawn.is_connected(_on_player_turn_start):
		Events.player_hand_drawn.disconnect(_on_player_turn_start)


func bind_run_state(value: RunState) -> void:
	_init_services()
	run_state = value
	_battle_active = false
	_pending_battle_start_trigger = false
	_cards_played_in_battle = 0
	_enemies_killed_in_battle = 0
	_battle_start_retry_count = 0
	_battle_context = null
	_battle_session_port = null
	effect_stack = null
	_rebuild_relic_runtime_cache()
	_sync_effect_executor()
	_apply_run_start_relics_once()
	battle_state_changed.emit(false)
	log_updated.emit("遗物/药水系统已就绪。")


func start_battle() -> void:
	_init_services()
	_battle_active = true
	_cards_played_in_battle = 0
	_enemies_killed_in_battle = 0
	_battle_start_retry_count = 0
	_relic_trigger_counts.clear()
	_pending_battle_start_trigger = true
	_sync_effect_executor()
	battle_state_changed.emit(true)
	_try_fire_battle_start_trigger()


func end_battle() -> void:
	if _battle_active:
		_fire_trigger(TriggerType.ON_BATTLE_END, {"kills": _enemies_killed_in_battle})
	_battle_active = false
	_pending_battle_start_trigger = false
	_battle_start_retry_count = 0
	_battle_context = null
	_battle_session_port = null
	effect_stack = null
	_sync_effect_executor()
	battle_state_changed.emit(false)


func on_battle_session_bound(session_port) -> void:
	_init_services()
	_battle_session_port = session_port
	effect_stack = session_port.effect_stack if session_port != null else null
	_battle_context = session_port.battle_context if session_port != null else null
	_sync_effect_executor()
	if not _battle_active:
		start_battle()
		return
	_battle_start_retry_count = 0
	_try_fire_battle_start_trigger()


func on_battle_scene_ready(battle_effect_stack: EffectStackEngine, battle_context_ref: BattleContext = null) -> void:
	var session_port = BATTLE_SESSION_PORT_SCRIPT.new(
		battle_effect_stack,
		battle_context_ref
	)
	on_battle_session_bound(session_port)


func is_battle_active() -> bool:
	return _battle_active


func _try_fire_battle_start_trigger() -> void:
	if not _pending_battle_start_trigger:
		return
	if not _battle_active:
		_pending_battle_start_trigger = false
		return
	if not _is_battle_start_context_ready():
		call_deferred("_deferred_try_fire_battle_start_trigger")
		return

	_pending_battle_start_trigger = false
	_fire_trigger(TriggerType.ON_BATTLE_START, {})


func _deferred_try_fire_battle_start_trigger() -> void:
	if not _pending_battle_start_trigger:
		return
	if not _battle_active:
		_pending_battle_start_trigger = false
		return
	if _is_battle_start_context_ready():
		_pending_battle_start_trigger = false
		_fire_trigger(TriggerType.ON_BATTLE_START, {})
		return

	_battle_start_retry_count += 1
	if _battle_start_retry_count > MAX_BATTLE_START_RETRIES:
		push_warning("[RelicPotionSystem] 战斗开始触发器等待超时（%d 次重试），放弃触发" % MAX_BATTLE_START_RETRIES)
		_pending_battle_start_trigger = false
		return

	var tree := get_tree()
	if tree == null:
		return
	tree.create_timer(0.01, false).timeout.connect(_try_fire_battle_start_trigger, CONNECT_ONE_SHOT)


func _is_battle_start_context_ready() -> bool:
	if effect_stack == null:
		return false
	if _battle_context != null:
		var context_player := _battle_context.get_player()
		if context_player != null and is_instance_valid(context_player):
			return true
	if _battle_session_port != null:
		var port_player: Variant = _battle_session_port.resolve_player()
		if port_player != null and is_instance_valid(port_player):
			return true
	return _find_player() != null


func use_potion(index: int) -> void:
	_init_services()
	_potion_use_service.use_potion(
		index,
		run_state,
		_battle_active,
		effect_stack,
		Callable(self, "_find_player"),
		Callable(self, "_find_enemies"),
		Callable(self, "_apply_potion_effect"),
		Callable(self, "_consume_potion"),
		Callable(self, "push_external_log")
	)


func push_external_log(text: String) -> void:
	if text.length() == 0:
		return
	log_updated.emit(text)


func fire_trigger(trigger_type: TriggerType, context: Dictionary) -> void:
	_fire_trigger(trigger_type, context)


func get_cards_played_in_battle() -> int:
	return _cards_played_in_battle


func get_relic_trigger_count(relic_id: String, trigger_type: String) -> int:
	var key := "%s:%s" % [relic_id, trigger_type]
	return int(_relic_trigger_counts.get(key, 0))


func get_relic_runtime_cache_snapshot() -> Dictionary:
	return _relic_runtimes.duplicate()


func increment_relic_trigger_count(relic_id: String, trigger_type: String) -> void:
	var key := "%s:%s" % [relic_id, trigger_type]
	var current := int(_relic_trigger_counts.get(key, 0))
	_relic_trigger_counts[key] = current + 1


func dispatch_relic_effect(effect_type: String, value: int, relic: RelicData) -> void:
	_dispatch_effect(effect_type, value, relic)


func _fire_trigger(trigger_type: TriggerType, context: Dictionary) -> void:
	if run_state == null:
		return

	trigger_fired.emit(trigger_type, context)

	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic

		# 使用缓存的运行时对象，避免每次触发都实例化
		var relic_runtime: Variant = _get_or_create_relic_runtime(relic_data)
		if relic_runtime == null:
			continue
		if not relic_runtime.has_method("handle_trigger"):
			continue
		relic_runtime.call("handle_trigger", int(trigger_type), context, self)


func _dispatch_effect(effect_type: String, value: int, _relic: RelicData) -> void:
	_init_services()
	_sync_effect_executor()
	_effect_executor.dispatch_effect(effect_type, value)


func _apply_relic_effect(effect_type: String, value: int) -> void:
	_init_services()
	_sync_effect_executor()
	_effect_executor.apply_effect(effect_type, value)


func _find_player() -> Player:
	if _battle_session_port != null:
		var port_player: Variant = _battle_session_port.resolve_player()
		if port_player is Player and is_instance_valid(port_player):
			return port_player as Player
	if not (Engine.get_main_loop() is SceneTree):
		return null
	var players: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("player")
	if players.is_empty():
		return null
	if players[0] is Player:
		return players[0] as Player
	return null


func _draw_cards_in_battle_context(amount: int) -> int:
	if amount <= 0:
		return 0
	var battle_context := _battle_context
	if battle_context == null and _battle_session_port != null:
		battle_context = _battle_session_port.battle_context
	if battle_context == null:
		battle_context = _find_battle_context()
	if battle_context == null:
		push_warning("[RelicPotionSystem] draw_cards 缺少 BattleContext，效果跳过")
		return 0
	return maxi(0, battle_context.draw_cards(amount))


func _find_battle_context() -> BattleContext:
	if _battle_session_port != null:
		return _battle_session_port.battle_context
	if _battle_context != null:
		return _battle_context
	return null


func _apply_potion_effect(index: int, potion: PotionData) -> void:
	if run_state == null or potion == null:
		return

	match potion.effect_type:
		PotionData.EffectType.HEAL:
			run_state.heal_player(maxi(0, potion.value))
			log_updated.emit("使用 %s：恢复 %d 生命" % [potion.title, maxi(0, potion.value)])
		PotionData.EffectType.GOLD:
			run_state.add_gold(maxi(0, potion.value))
			log_updated.emit("使用 %s：获得 %d 金币" % [potion.title, maxi(0, potion.value)])
		PotionData.EffectType.BLOCK:
			if run_state.player_stats != null:
				var block_gain := maxi(0, potion.value)
				run_state.player_stats.block += block_gain
				if block_gain > 0:
					Events.player_block_applied.emit(block_gain, "potion")
				run_state.emit_changed()
			log_updated.emit("使用 %s：获得 %d 格挡" % [potion.title, maxi(0, potion.value)])
		PotionData.EffectType.DAMAGE_ALL_ENEMIES:
			log_updated.emit("使用 %s：战斗外无有效目标" % potion.title)
		_:
			log_updated.emit("使用 %s：无效果" % potion.title)
	_consume_potion(index, potion)


func _on_card_played(card: Card) -> void:
	if not _can_process_battle_trigger():
		return

	_cards_played_in_battle += 1
	
	var context := {"card": card}
	
	if card != null:
		if card.type == Card.Type.ATTACK:
			_emit_battle_trigger(TriggerType.ON_ATTACK_PLAYED, context)
		elif card.type == Card.Type.SKILL:
			_emit_battle_trigger(TriggerType.ON_SKILL_PLAYED, context)

	_emit_battle_trigger(TriggerType.ON_CARD_PLAYED, context)


func _on_player_hit() -> void:
	_emit_battle_trigger(TriggerType.ON_DAMAGE_TAKEN, {})


func _on_player_block_applied(amount: int, source: String) -> void:
	_emit_battle_trigger(TriggerType.ON_BLOCK_APPLIED, {
		"amount": maxi(0, amount),
		"source": source,
	})


func _on_enemy_died(_enemy: Enemy) -> void:
	if not _can_process_battle_trigger():
		return
	
	_enemies_killed_in_battle += 1
	_emit_battle_trigger(TriggerType.ON_ENEMY_KILLED, {"count": _enemies_killed_in_battle})


func _on_player_turn_start() -> void:
	_emit_battle_trigger(TriggerType.ON_TURN_START, {})


func _on_player_turn_end() -> void:
	_emit_battle_trigger(TriggerType.ON_TURN_END, {})


func on_shop_enter() -> void:
	_emit_run_trigger(TriggerType.ON_SHOP_ENTER, {})


func on_boss_killed() -> void:
	_emit_run_trigger(TriggerType.ON_BOSS_KILLED, {})


func _can_process_battle_trigger() -> bool:
	return _battle_active and run_state != null


func _emit_battle_trigger(trigger_type: TriggerType, context: Dictionary = {}) -> void:
	if not _can_process_battle_trigger():
		return
	_fire_trigger(trigger_type, context)


func _emit_run_trigger(trigger_type: TriggerType, context: Dictionary = {}) -> void:
	if run_state == null:
		return
	_fire_trigger(trigger_type, context)


func _rebuild_relic_runtime_cache() -> void:
	_init_services()
	_runtime_cache.rebuild(run_state)


func _get_or_create_relic_runtime(relic_data: RelicData) -> Variant:
	_init_services()
	return _runtime_cache.resolve(relic_data)


func add_relic(relic: RelicData) -> void:
	if relic == null or relic.id.is_empty():
		return
	if run_state == null:
		return
	if run_state.add_relic(relic):
		_runtime_cache.prime_relic(relic)


func remove_relic(relic_id: String) -> bool:
	if relic_id.is_empty() or run_state == null:
		return false
	_runtime_cache.remove(relic_id)
	for i in run_state.relics.size():
		if run_state.relics[i].id == relic_id:
			run_state.relics.remove_at(i)
			run_state.emit_changed()
			return true
	return false


func _apply_run_start_relics_once() -> void:
	if run_state == null:
		return
	if run_state.run_start_relics_applied:
		return

	# 仅在新局起点触发，避免中途读档重复获得开局收益。
	var is_fresh_run := run_state.floor <= 0 and run_state.map_visited_node_ids.is_empty()
	if is_fresh_run:
		_fire_trigger(TriggerType.ON_RUN_START, {})
	run_state.run_start_relics_applied = true
	run_state.emit_changed()


func _consume_potion(index: int, potion: PotionData) -> void:
	if run_state == null:
		return
	if index >= 0 and index < run_state.potions.size() and run_state.potions[index] == potion:
		run_state.potions.remove_at(index)
	else:
		var fallback_index := run_state.potions.find(potion)
		if fallback_index != -1:
			run_state.potions.remove_at(fallback_index)
	run_state.emit_changed()


func _find_enemies() -> Array[Node]:
	if _battle_session_port != null:
		var port_enemies: Variant = _battle_session_port.resolve_enemies()
		if not (port_enemies is Array):
			port_enemies = []
		if not port_enemies.is_empty():
			var typed_enemies: Array[Node] = []
			for enemy in port_enemies:
				if enemy is Node and is_instance_valid(enemy):
					typed_enemies.append(enemy)
			return typed_enemies

	var result: Array[Node] = []
	if not (Engine.get_main_loop() is SceneTree):
		return result
	var nodes: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("enemies")
	for node in nodes:
		if node != null and is_instance_valid(node):
			result.append(node)
	return result


func _init_services() -> void:
	if _runtime_cache == null:
		_runtime_cache = RELIC_RUNTIME_CACHE_SCRIPT.new()
	if _effect_executor == null:
		_effect_executor = RELIC_EFFECT_EXECUTOR_SCRIPT.new()
	if _potion_use_service == null:
		_potion_use_service = POTION_USE_SERVICE_SCRIPT.new()
	_effect_executor.bind_resolvers(Callable(self, "_find_player"), Callable(self, "_draw_cards_in_battle_context"))


func _sync_effect_executor() -> void:
	_init_services()
	_effect_executor.bind_run_state(run_state)
	_effect_executor.bind_battle_session(effect_stack, _battle_active)
