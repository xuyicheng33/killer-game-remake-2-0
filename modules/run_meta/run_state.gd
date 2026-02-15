class_name RunState
extends Resource

@export var seed: int = 0
@export var act: int = 1
@export var floor: int = 0
@export var gold: int = 99

var player_stats: CharacterStats


func init_with_character(base_stats: CharacterStats, run_seed: int) -> void:
	seed = run_seed
	act = 1
	floor = 0
	gold = 99

	player_stats = base_stats.create_instance()
	if not player_stats.stats_changed.is_connected(_on_player_stats_changed):
		player_stats.stats_changed.connect(_on_player_stats_changed)

	emit_changed()


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	emit_changed()


func next_floor() -> void:
	floor += 1
	emit_changed()


func _on_player_stats_changed() -> void:
	emit_changed()
