class_name RelicPotionSystem
extends Node

signal log_updated(text: String)

var run_state: RunState
var _battle_active := false
var _cards_played_in_battle := 0


func _ready() -> void:
	_connect_signals()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played)
	if not Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.connect(_on_player_hit)


func _disconnect_signals() -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)


func bind_run_state(value: RunState) -> void:
	run_state = value
	_battle_active = false
	_cards_played_in_battle = 0
	log_updated.emit("遗物/药水系统已就绪。")


func start_battle() -> void:
	_battle_active = true
	_cards_played_in_battle = 0
	_trigger_battle_start()


func end_battle() -> void:
	_battle_active = false


func use_potion(index: int) -> void:
	if run_state == null:
		return
	var message := run_state.use_potion_at(index)
	if message.length() > 0:
		log_updated.emit(message)


func push_external_log(text: String) -> void:
	if text.length() == 0:
		return
	log_updated.emit(text)


func _trigger_battle_start() -> void:
	if run_state == null:
		return

	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		if relic_data.on_battle_start_heal <= 0:
			continue

		run_state.heal_player(relic_data.on_battle_start_heal)
		log_updated.emit("%s 触发：战斗开始恢复 %d 生命" % [relic_data.title, relic_data.on_battle_start_heal])


func _on_card_played(_card: Card) -> void:
	if not _battle_active or run_state == null:
		return

	_cards_played_in_battle += 1
	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		if relic_data.on_card_played_gold <= 0:
			continue

		var interval := maxi(1, relic_data.card_play_interval)
		if _cards_played_in_battle % interval != 0:
			continue

		run_state.add_gold(relic_data.on_card_played_gold)
		log_updated.emit("%s 触发：出牌后获得 %d 金币" % [relic_data.title, relic_data.on_card_played_gold])


func _on_player_hit() -> void:
	if not _battle_active or run_state == null:
		return
	if run_state.player_stats == null:
		return

	for relic in run_state.relics:
		if not (relic is RelicData):
			continue
		var relic_data: RelicData = relic
		if relic_data.on_player_hit_block <= 0:
			continue

		run_state.player_stats.block += relic_data.on_player_hit_block
		log_updated.emit("%s 触发：受击后获得 %d 格挡" % [relic_data.title, relic_data.on_player_hit_block])

