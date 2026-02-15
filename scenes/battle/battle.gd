extends Node2D

const BATTLE_PHASE_STATE_MACHINE_SCRIPT := preload("res://modules/battle_loop/battle_phase_state_machine.gd")
const PHASE_LOG_LIMIT := 8

@export var char_stats: CharacterStats
@export var music: AudioStream
@export var runtime_stats: CharacterStats

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var current_phase_label: Label = %CurrentPhaseLabel
@onready var phase_log_label: Label = %PhaseLogLabel

var _battle_phase_machine: BattlePhaseStateMachine
var _phase_logs: Array[String] = []
var _battle_ended := false
var _battle_setup_done := false
var _active_stats: CharacterStats


func _ready() -> void:
	_active_stats = runtime_stats if runtime_stats else char_stats.create_instance()
	battle_ui.char_stats = _active_stats
	player.stats = _active_stats
	
	_battle_phase_machine = BATTLE_PHASE_STATE_MACHINE_SCRIPT.new()
	_battle_phase_machine.phase_changed.connect(_on_phase_changed)

	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	Events.player_turn_ended.connect(_on_player_turn_ended)
	Events.player_hand_discarded.connect(_on_player_hand_discarded)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	Events.player_died.connect(_on_player_died)
	
	start_battle(_active_stats)


func start_battle(stats: CharacterStats) -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	_active_stats = stats
	_battle_ended = false
	_battle_setup_done = false
	_phase_logs.clear()
	enemy_handler.reset_enemy_actions()
	_battle_phase_machine.start()


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		_battle_ended = true
		Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_player_hand_drawn() -> void:
	if _battle_ended:
		return

	_battle_phase_machine.transition_to(BattlePhaseStateMachine.Phase.ACTION)


func _on_player_turn_ended() -> void:
	if _battle_ended:
		return
	if _battle_phase_machine.get_phase() != BattlePhaseStateMachine.Phase.ACTION:
		return

	player_handler.end_turn()


func _on_player_hand_discarded() -> void:
	if _battle_ended:
		return

	_battle_phase_machine.transition_to(BattlePhaseStateMachine.Phase.ENEMY)


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

	match to_phase:
		BattlePhaseStateMachine.Phase.DRAW:
			_enter_draw_phase()
		BattlePhaseStateMachine.Phase.ENEMY:
			_enter_enemy_phase()
		BattlePhaseStateMachine.Phase.RESOLVE:
			_enter_resolve_phase()


func _enter_draw_phase() -> void:
	if _battle_setup_done:
		player_handler.start_turn()
		return

	player_handler.start_battle(_active_stats)
	_battle_setup_done = true


func _enter_enemy_phase() -> void:
	if enemy_handler.get_child_count() == 0:
		_battle_ended = true
		Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)
		return

	enemy_handler.start_turn()


func _enter_resolve_phase() -> void:
	enemy_handler.reset_enemy_actions()
	_battle_phase_machine.transition_to(BattlePhaseStateMachine.Phase.DRAW)


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
	_battle_ended = true
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
