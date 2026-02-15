extends Node2D

@export var char_stats: CharacterStats
@export var music: AudioStream
@export var runtime_stats: CharacterStats

@onready var battle_ui: BattleUI = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player


func _ready() -> void:
	var active_stats := runtime_stats if runtime_stats else char_stats.create_instance()
	battle_ui.char_stats = active_stats
	player.stats = active_stats
	
	enemy_handler.child_order_changed.connect(_on_enemies_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	Events.player_died.connect(_on_player_died)
	
	start_battle(active_stats)


func start_battle(stats: CharacterStats) -> void:
	get_tree().paused = false
	MusicPlayer.play(music, true)
	enemy_handler.reset_enemy_actions()
	player_handler.start_battle(stats)


func _on_enemies_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		Events.battle_over_screen_requested.emit("Victorious!", BattleOverPanel.Type.WIN)


func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_actions()


func _on_player_died() -> void:
	Events.battle_over_screen_requested.emit("Game Over!", BattleOverPanel.Type.LOSE)
