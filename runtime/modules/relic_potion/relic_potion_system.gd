class_name RelicPotionSystem
extends Node

enum TriggerType {
	ON_BATTLE_START,
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
var _cards_played_in_battle := 0
var _enemies_killed_in_battle := 0


func _ready() -> void:
	_connect_signals()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)
	if not Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.connect(_on_player_hit)
	if not Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.connect(_on_enemy_died)
	if not Events.player_turn_ended.is_connected(_on_player_turn_end):
		Events.player_turn_ended.connect(_on_player_turn_end)
	if not Events.player_hand_drawn.is_connected(_on_player_turn_start):
		Events.player_hand_drawn.connect(_on_player_turn_start)


func _disconnect_signals() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)
	if Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.disconnect(_on_enemy_died)
	if Events.player_turn_ended.is_connected(_on_player_turn_end):
		Events.player_turn_ended.disconnect(_on_player_turn_end)
	if Events.player_hand_drawn.is_connected(_on_player_turn_start):
		Events.player_hand_drawn.disconnect(_on_player_turn_start)


func bind_run_state(value: RunState) -> void:
	run_state = value
	_battle_active = false
	_cards_played_in_battle = 0
	_enemies_killed_in_battle = 0
	_fire_trigger(TriggerType.ON_RUN_START, {})
	log_updated.emit("遗物/药水系统已就绪。")


func start_battle() -> void:
	_battle_active = true
	_cards_played_in_battle = 0
	_enemies_killed_in_battle = 0
	_fire_trigger(TriggerType.ON_BATTLE_START, {})


func end_battle() -> void:
	_battle_active = false


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


func _fire_trigger(trigger_type: TriggerType, context: Dictionary) -> void:
	if run_state == null:
		return
	
	trigger_fired.emit(trigger_type, context)
	
	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		_process_relic_trigger(relic_data, trigger_type, context)


func _process_relic_trigger(relic: RelicData, trigger_type: TriggerType, context: Dictionary) -> void:
	match trigger_type:
		TriggerType.ON_BATTLE_START:
			if relic.on_battle_start_heal > 0:
				_dispatch_effect("heal", relic.on_battle_start_heal, relic)
				log_updated.emit("%s 触发：战斗开始恢复 %d 生命" % [relic.title, relic.on_battle_start_heal])

		TriggerType.ON_TURN_START:
			if relic.on_turn_start_block > 0:
				_dispatch_effect("add_block", relic.on_turn_start_block, relic)
				log_updated.emit("%s 触发：回合开始获得 %d 格挡" % [relic.title, relic.on_turn_start_block])

		TriggerType.ON_TURN_END:
			if relic.on_turn_end_heal > 0:
				_dispatch_effect("heal", relic.on_turn_end_heal, relic)
				log_updated.emit("%s 触发：回合结束恢复 %d 生命" % [relic.title, relic.on_turn_end_heal])
		
		TriggerType.ON_CARD_PLAYED:
			if relic.on_card_played_gold > 0:
				var interval := maxi(1, relic.card_play_interval)
				if _cards_played_in_battle % interval == 0:
					_dispatch_effect("add_gold", relic.on_card_played_gold, relic)
					log_updated.emit("%s 触发：出牌后获得 %d 金币" % [relic.title, relic.on_card_played_gold])
		
		TriggerType.ON_DAMAGE_TAKEN:
			if relic.on_player_hit_block > 0:
				_dispatch_effect("add_block", relic.on_player_hit_block, relic)
				log_updated.emit("%s 触发：受击后获得 %d 格挡" % [relic.title, relic.on_player_hit_block])
		
		TriggerType.ON_ENEMY_KILLED:
			if relic.on_enemy_killed_gold > 0:
				_dispatch_effect("add_gold", relic.on_enemy_killed_gold, relic)
				log_updated.emit("%s 触发：击杀敌人获得 %d 金币" % [relic.title, relic.on_enemy_killed_gold])

		TriggerType.ON_SHOP_ENTER:
			if relic.shop_discount_percent > 0:
				log_updated.emit("%s 生效：商店折扣 %d%%" % [relic.title, relic.shop_discount_percent])


func _dispatch_effect(effect_type: String, value: int, relic: RelicData) -> void:
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
				run_state.player_stats.block += value


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
				run_state.player_stats.block += maxi(0, potion.value)
				run_state.emit_changed()
			log_updated.emit("使用 %s：获得 %d 格挡" % [potion.title, maxi(0, potion.value)])
		_:
			log_updated.emit("使用 %s：无效果" % potion.title)

	if index >= 0 and index < run_state.potions.size() and run_state.potions[index] == potion:
		run_state.potions.remove_at(index)
	else:
		var fallback_index := run_state.potions.find(potion)
		if fallback_index != -1:
			run_state.potions.remove_at(fallback_index)
	run_state.emit_changed()


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
