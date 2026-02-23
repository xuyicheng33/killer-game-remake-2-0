extends Node2D

const BATTLE_CONTEXT_SCRIPT := preload("res://runtime/modules/battle_loop/battle_context.gd")
const BATTLE_SESSION_PORT_SCRIPT := preload("res://runtime/modules/relic_potion/contracts/battle_session_port.gd")
const ENEMY_SPAWN_SERVICE_SCRIPT := preload("res://runtime/modules/battle_loop/enemy_spawn_service.gd")
const PHASE_LOG_LIMIT := 8

@export var char_stats: CharacterStats
@export var music: AudioStream
@export var runtime_stats: CharacterStats
@export var encounter_id: String = ""
var relic_potion_system: RelicPotionSystem = null

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var hand_container: HBoxContainer = $BattleUI/Hand
@onready var end_turn_button: Button = $BattleUI/EndTurnButton
@onready var phase_panel: PanelContainer = $PhaseHUD/Panel
@onready var current_phase_label: Label = %CurrentPhaseLabel
@onready var phase_log_label: Label = %PhaseLogLabel

var _battle_phase_machine: BattlePhaseStateMachine
var _battle_context: BattleContext
var _enemy_spawn_service = null
var _phase_logs: Array[String] = []
var _battle_ended := false
var _active_stats: CharacterStats


func _ready() -> void:
	_active_stats = runtime_stats if runtime_stats else char_stats.create_instance()
	battle_ui.char_stats = _active_stats
	player.stats = _active_stats

	_battle_context = BATTLE_CONTEXT_SCRIPT.new()
	_enemy_spawn_service = ENEMY_SPAWN_SERVICE_SCRIPT.new()
	battle_ui.bind_battle_context(_battle_context)

	_apply_responsive_layout()
	_connect_signals()

	_battle_phase_machine = _battle_context.phase_machine
	if _battle_phase_machine != null and not _battle_phase_machine.phase_changed.is_connected(_on_phase_changed):
		_battle_phase_machine.phase_changed.connect(_on_phase_changed)
	if _battle_phase_machine != null and not _battle_phase_machine.battle_ended.is_connected(_on_battle_ended):
		_battle_phase_machine.battle_ended.connect(_on_battle_ended)
	if _battle_phase_machine != null:
		_battle_phase_machine.bind_turn_handlers(player_handler, enemy_handler)

	start_battle(_active_stats)


func _exit_tree() -> void:
	MusicPlayer.stop()
	_disconnect_signals()
	if _battle_phase_machine != null and _battle_phase_machine.phase_changed.is_connected(_on_phase_changed):
		_battle_phase_machine.phase_changed.disconnect(_on_phase_changed)
	if _battle_phase_machine != null and _battle_phase_machine.battle_ended.is_connected(_on_battle_ended):
		_battle_phase_machine.battle_ended.disconnect(_on_battle_ended)
	if _battle_context != null:
		_battle_context.unbind_battle_context()
		_battle_context = null


func _connect_signals() -> void:
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	if not Events.player_hand_drawn.is_connected(_on_player_hand_drawn):
		Events.player_hand_drawn.connect(_on_player_hand_drawn)
	if not Events.player_turn_ended.is_connected(_on_player_turn_ended):
		Events.player_turn_ended.connect(_on_player_turn_ended)
	if not Events.player_hand_discarded.is_connected(_on_player_hand_discarded):
		Events.player_hand_discarded.connect(_on_player_hand_discarded)
	if not Events.enemy_turn_ended.is_connected(_on_enemy_turn_ended):
		Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	if not Events.player_died.is_connected(_on_player_died):
		Events.player_died.connect(_on_player_died)
	if not Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.connect(_on_enemy_died)


func _disconnect_signals() -> void:
	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if Events.player_hand_drawn.is_connected(_on_player_hand_drawn):
		Events.player_hand_drawn.disconnect(_on_player_hand_drawn)
	if Events.player_turn_ended.is_connected(_on_player_turn_ended):
		Events.player_turn_ended.disconnect(_on_player_turn_ended)
	if Events.player_hand_discarded.is_connected(_on_player_hand_discarded):
		Events.player_hand_discarded.disconnect(_on_player_hand_discarded)
	if Events.enemy_turn_ended.is_connected(_on_enemy_turn_ended):
		Events.enemy_turn_ended.disconnect(_on_enemy_turn_ended)
	if Events.player_died.is_connected(_on_player_died):
		Events.player_died.disconnect(_on_player_died)
	if Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.disconnect(_on_enemy_died)


func start_battle(stats: CharacterStats) -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	_active_stats = stats
	_battle_ended = false
	_phase_logs.clear()
	_battle_context.bind_battle_context(_active_stats, battle_ui.hand_container)
	var enemies: Array[Enemy] = _enemy_spawn_service.spawn_enemies(
		enemy_handler,
		_battle_context,
		encounter_id,
		get_viewport_rect().size.x
	)
	if enemies.is_empty():
		push_error("battle.gd: battle setup aborted, no valid enemies were spawned")
		_on_battle_ended("defeat")
		return
	_battle_context.bind_combatants(player, enemies)
	enemy_handler.reset_enemy_actions()
	_bind_battle_session_to_relic_system()
	_battle_context.start_battle()


func _bind_battle_session_to_relic_system() -> void:
	if relic_potion_system == null:
		return

	var session_port := BATTLE_SESSION_PORT_SCRIPT.new(
		_battle_context.effect_stack,
		_battle_context,
		func() -> Player:
			return player,
		func() -> Array[Node]:
			return _resolve_live_enemies()
	)

	relic_potion_system.on_battle_session_bound(session_port)


func _resolve_live_enemies() -> Array[Node]:
	var out: Array[Node] = []
	for enemy in _enemy_spawn_service.collect_battle_enemies(enemy_handler):
		if enemy != null and is_instance_valid(enemy):
			out.append(enemy)
	return out


func _on_enemies_child_order_changed() -> void:
	pass


func _on_player_hand_drawn() -> void:
	if _battle_ended:
		return

	_battle_phase_machine.transition_to(BattlePhaseStateMachine.Phase.ACTION)


func _on_player_turn_ended() -> void:
	if _battle_ended:
		return
	if _battle_phase_machine.get_phase() != BattlePhaseStateMachine.Phase.ACTION:
		return

	_battle_phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)


func _on_player_hand_discarded() -> void:
	if _battle_ended:
		return
	if _battle_phase_machine.get_phase() != BattlePhaseStateMachine.Phase.RESOLVE:
		return
	_battle_phase_machine.on_resolve_discard_completed()


func _on_enemy_turn_ended() -> void:
	if _battle_ended:
		return

	if _battle_phase_machine.get_phase() != BattlePhaseStateMachine.Phase.ENEMY:
		return

	_battle_phase_machine.transition_to(BattlePhaseStateMachine.Phase.RESOLVE)


func _on_phase_changed(from_phase: BattlePhaseStateMachine.Phase, to_phase: BattlePhaseStateMachine.Phase, turn: int) -> void:
	var from_phase_name := _battle_phase_machine.get_phase_name(from_phase)
	var to_phase_name := _battle_phase_machine.get_phase_name(to_phase)
	var log_text := "T%s %s -> %s" % [str(turn), from_phase_name, to_phase_name]
	_append_phase_log(log_text)
	_update_phase_hud(to_phase_name, turn)

	if _battle_ended:
		return


func _get_battle_enemies() -> Array[Enemy]:
	return _enemy_spawn_service.collect_battle_enemies(enemy_handler)


func _append_phase_log(text: String) -> void:
	_phase_logs.append(text)
	if _phase_logs.size() > PHASE_LOG_LIMIT:
		_phase_logs.pop_front()


func _update_phase_hud(phase_name: String, turn: int) -> void:
	current_phase_label.text = "回合 %d | 阶段：%s" % [turn, phase_name]

	var combined_log := "阶段日志："
	for entry in _phase_logs:
		combined_log += "\n%s" % entry
	phase_log_label.text = combined_log


func _on_player_died() -> void:
	if _battle_ended:
		return
	_on_battle_ended("defeat")


func _on_enemy_died(enemy: Enemy) -> void:
	if _battle_ended:
		return

	# 使用 BattleContext 统一入口移除敌人（同步 BuffSystem 敌人列表）
	if _battle_context != null:
		_battle_context.remove_enemy(enemy)

	# 从敌人处理器中移除并释放节点
	if enemy != null and is_instance_valid(enemy):
		enemy.get_parent().remove_child(enemy)
		enemy.queue_free()

	# 立即检查战斗是否结束（DOT击杀或普通击杀都应触发）
	if _battle_phase_machine != null:
		var battle_result := _battle_phase_machine.check_battle_end()
		if battle_result.ended:
			_on_battle_ended(battle_result.result)


func _on_battle_ended(result: String) -> void:
	if _battle_ended:
		return
	_battle_ended = true
	MusicPlayer.stop()
	var panel_type := BattleOverPanel.Type.WIN
	var text := "Victorious!"
	if result != "victory":
		panel_type = BattleOverPanel.Type.LOSE
		text = "Game Over!"
	Events.battle_over_screen_requested.emit(text, panel_type)


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size

	var hand_width := clampf(viewport_size.x * 0.62, 680.0, 1180.0)
	var hand_top := -clampf(viewport_size.y * 0.24, 170.0, 280.0)
	hand_container.offset_left = -hand_width * 0.5
	hand_container.offset_right = hand_width * 0.5
	hand_container.offset_top = hand_top

	var right_margin := clampf(viewport_size.x * 0.02, 18.0, 40.0)
	var bottom_margin := clampf(viewport_size.y * 0.02, 18.0, 34.0)
	var button_width := clampf(viewport_size.x * 0.12, 180.0, 280.0)
	var button_height := clampf(viewport_size.y * 0.09, 58.0, 86.0)
	end_turn_button.offset_left = -(button_width + right_margin)
	end_turn_button.offset_top = -(button_height + bottom_margin)
	end_turn_button.offset_right = -right_margin
	end_turn_button.offset_bottom = -bottom_margin

	var phase_width := clampf(viewport_size.x * 0.24, 320.0, 520.0)
	var phase_height := clampf(viewport_size.y * 0.22, 170.0, 280.0)
	var phase_margin := clampf(viewport_size.x * 0.012, 12.0, 24.0)
	phase_panel.offset_left = phase_margin
	phase_panel.offset_top = phase_margin
	phase_panel.offset_right = phase_margin + phase_width
	phase_panel.offset_bottom = phase_margin + phase_height
