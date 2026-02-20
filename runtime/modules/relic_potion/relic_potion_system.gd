class_name RelicPotionSystem
extends Node

const RELIC_REGISTRY_SCRIPT := preload("res://runtime/modules/relic_potion/relic_registry.gd")

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

var run_state: RunState
var effect_stack: EffectStackEngine = null
var _battle_active := false
var _pending_battle_start_trigger := false
var _cards_played_in_battle := 0
var _enemies_killed_in_battle := 0
var _battle_start_retry_count := 0
var _relic_runtimes: Dictionary = {}  # 遗物ID -> 运行时对象缓存
const MAX_BATTLE_START_RETRIES := 100


func _ready() -> void:
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
	run_state = value
	_battle_active = false
	_pending_battle_start_trigger = false
	_cards_played_in_battle = 0
	_enemies_killed_in_battle = 0
	_rebuild_relic_runtime_cache()
	_apply_run_start_relics_once()
	log_updated.emit("遗物/药水系统已就绪。")


func start_battle() -> void:
	_battle_active = true
	_cards_played_in_battle = 0
	_enemies_killed_in_battle = 0
	_battle_start_retry_count = 0
	_pending_battle_start_trigger = true
	_try_fire_battle_start_trigger()


func end_battle() -> void:
	if _battle_active:
		_fire_trigger(TriggerType.ON_BATTLE_END, {"kills": _enemies_killed_in_battle})
	_battle_active = false
	_pending_battle_start_trigger = false


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
	return _find_player() != null


func use_potion(index: int) -> void:
	if run_state == null:
		return
	if index < 0 or index >= run_state.potions.size():
		return
	var potion: PotionData = run_state.potions[index]
	if potion == null:
		return
	if effect_stack == null:
		push_warning("[RelicPotionSystem] effect_stack 未注入，药水效果无法派发")
		return
	if potion.effect_type == PotionData.EffectType.DAMAGE_ALL_ENEMIES:
		_use_damage_potion(index, potion)
		return
	var player := _find_player()
	if player == null:
		push_warning("[RelicPotionSystem] 未找到 player，药水效果无法派发")
		return

	effect_stack.enqueue_effect(
		"potion_%s" % potion.id,
		[player],
		func(_target: Node) -> void:
			_apply_potion_effect(index, potion),
		50,
		_potion_effect_type(potion),
		null,
		potion.value
	)


func push_external_log(text: String) -> void:
	if text.length() == 0:
		return
	log_updated.emit(text)


func fire_trigger(trigger_type: TriggerType, context: Dictionary) -> void:
	_fire_trigger(trigger_type, context)


func get_cards_played_in_battle() -> int:
	return _cards_played_in_battle


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


func _dispatch_effect(effect_type: String, value: int, relic: RelicData) -> void:
	if effect_type == "add_gold" or effect_type == "increase_max_health":
		_apply_relic_effect(effect_type, value)
		return
	if effect_stack == null:
		push_warning("[RelicPotionSystem] effect_stack 未注入，遗物效果无法派发: %s" % effect_type)
		return
	var player := _find_player()
	if player == null:
		push_warning("[RelicPotionSystem] 未找到 player，遗物效果无法派发: %s" % effect_type)
		return
	
	effect_stack.enqueue_effect(
		"relic_%s" % effect_type,
		[player],
		func(_target: Node) -> void:
			_apply_relic_effect(effect_type, value),
		50,
		EffectStackEngine.EffectType.SPECIAL,
		null,
		value
	)


func _apply_relic_effect(effect_type: String, value: int) -> void:
	if run_state == null:
		return
	
	match effect_type:
		"heal":
			run_state.heal_player(value)
		"add_gold":
			run_state.add_gold(value)
		"add_block":
			if run_state.player_stats != null:
				var block_gain := maxi(0, value)
				run_state.player_stats.block += block_gain
				if block_gain > 0:
					Events.player_block_applied.emit(block_gain, "relic")
		"increase_max_health":
			run_state.increase_max_health(value)
		"add_energy":
			if run_state.player_stats != null:
				var char_stats: CharacterStats = run_state.player_stats
				char_stats.mana = mini(char_stats.mana + value, char_stats.max_mana)
				run_state.emit_changed()
		"take_damage":
			if run_state.player_stats != null:
				run_state.player_stats.take_damage(maxi(0, value))
		"add_strength":
			if run_state.player_stats != null:
				run_state.player_stats.add_status("strength", value)
		"draw_cards":
			if run_state.player_stats != null and value > 0:
				for i in range(value):
					if run_state.player_stats.draw_pile != null and not run_state.player_stats.draw_pile.cards.is_empty():
						var card: Card = run_state.player_stats.draw_pile.draw_card()
						if card != null:
							run_state.player_stats.discard.add_card(card)
				run_state.emit_changed()


func _find_player() -> Player:
	if not (Engine.get_main_loop() is SceneTree):
		return null
	var players: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("player")
	if players.is_empty():
		return null
	if players[0] is Player:
		return players[0] as Player
	return null


func _potion_effect_type(potion: PotionData) -> EffectStackEngine.EffectType:
	match potion.effect_type:
		PotionData.EffectType.HEAL:
			return EffectStackEngine.EffectType.HEAL
		PotionData.EffectType.BLOCK:
			return EffectStackEngine.EffectType.BLOCK
		PotionData.EffectType.DAMAGE_ALL_ENEMIES:
			return EffectStackEngine.EffectType.DAMAGE
		_:
			return EffectStackEngine.EffectType.SPECIAL


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
	if not _battle_active or run_state == null:
		return

	_cards_played_in_battle += 1
	
	var context := {"card": card}
	
	if card != null:
		if card.type == Card.Type.ATTACK:
			_fire_trigger(TriggerType.ON_ATTACK_PLAYED, context)
		elif card.type == Card.Type.SKILL:
			_fire_trigger(TriggerType.ON_SKILL_PLAYED, context)
	
	_fire_trigger(TriggerType.ON_CARD_PLAYED, context)


func _on_player_hit() -> void:
	if not _battle_active or run_state == null:
		return
	
	_fire_trigger(TriggerType.ON_DAMAGE_TAKEN, {})


func _on_player_block_applied(amount: int, source: String) -> void:
	if not _battle_active or run_state == null:
		return
	_fire_trigger(TriggerType.ON_BLOCK_APPLIED, {
		"amount": maxi(0, amount),
		"source": source,
	})


func _on_enemy_died(_enemy: Enemy) -> void:
	if not _battle_active or run_state == null:
		return
	
	_enemies_killed_in_battle += 1
	_fire_trigger(TriggerType.ON_ENEMY_KILLED, {"count": _enemies_killed_in_battle})


func _on_player_turn_start() -> void:
	if not _battle_active or run_state == null:
		return
	
	_fire_trigger(TriggerType.ON_TURN_START, {})


func _on_player_turn_end() -> void:
	if not _battle_active or run_state == null:
		return
	
	_fire_trigger(TriggerType.ON_TURN_END, {})


func on_shop_enter() -> void:
	if run_state == null:
		return
	
	_fire_trigger(TriggerType.ON_SHOP_ENTER, {})


func on_boss_killed() -> void:
	if run_state == null:
		return
	
	_fire_trigger(TriggerType.ON_BOSS_KILLED, {})


func _rebuild_relic_runtime_cache() -> void:
	_relic_runtimes.clear()
	if run_state == null:
		return
	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		if relic_data.id.is_empty():
			continue
		var runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic_data)
		if runtime != null:
			_relic_runtimes[relic_data.id] = runtime


func _get_or_create_relic_runtime(relic_data: RelicData) -> Variant:
	if relic_data == null or relic_data.id.is_empty():
		return null
	if _relic_runtimes.has(relic_data.id):
		return _relic_runtimes[relic_data.id]
	var runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic_data)
	if runtime != null:
		_relic_runtimes[relic_data.id] = runtime
	return runtime


func add_relic(relic: RelicData) -> void:
	if relic == null or relic.id.is_empty():
		return
	if run_state == null:
		return
	if run_state.add_relic(relic):
		var runtime: Variant = RELIC_REGISTRY_SCRIPT.create_relic(relic)
		if runtime != null:
			_relic_runtimes[relic.id] = runtime


func remove_relic(relic_id: String) -> bool:
	if relic_id.is_empty() or run_state == null:
		return false
	_relic_runtimes.erase(relic_id)
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


func _use_damage_potion(index: int, potion: PotionData) -> void:
	var enemies := _find_enemies()
	if enemies.is_empty():
		log_updated.emit("使用 %s：无有效目标" % potion.title)
		_consume_potion(index, potion)
		return

	var damage := maxi(0, potion.value)
	effect_stack.enqueue_effect(
		"potion_%s" % potion.id,
		enemies,
		_apply_potion_damage_to_enemy.bind(damage),
		50,
		EffectStackEngine.EffectType.DAMAGE,
		null,
		damage
	)
	_consume_potion(index, potion)
	log_updated.emit("使用 %s：对所有敌人造成 %d 伤害" % [potion.title, damage])


func _apply_potion_damage_to_enemy(target: Node, damage: int) -> void:
	if target == null or not is_instance_valid(target):
		return
	if damage <= 0:
		return
	if target.has_method("take_damage"):
		target.call("take_damage", damage)


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
	var result: Array[Node] = []
	if not (Engine.get_main_loop() is SceneTree):
		return result
	var nodes: Array[Node] = (Engine.get_main_loop() as SceneTree).get_nodes_in_group("enemies")
	for node in nodes:
		if node != null and is_instance_valid(node):
			result.append(node)
	return result
