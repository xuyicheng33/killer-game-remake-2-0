class_name RunState
extends Resource

const MAP_GENERATOR_SCRIPT := preload("res://modules/map_event/map_generator.gd")

@export var seed: int = 0
@export var act: int = 1
@export var floor: int = 0
@export var gold: int = 99
@export var map_current_node_id: String = ""
@export var map_reachable_node_ids: PackedStringArray = PackedStringArray()
@export var map_visited_node_ids: PackedStringArray = PackedStringArray()

var player_stats: CharacterStats
var map_graph: MapGraphData


func init_with_character(base_stats: CharacterStats, run_seed: int) -> void:
	seed = run_seed
	act = 1
	floor = 0
	gold = 99

	player_stats = base_stats.create_instance()
	if not player_stats.stats_changed.is_connected(_on_player_stats_changed):
		player_stats.stats_changed.connect(_on_player_stats_changed)

	_init_map_progression()
	emit_changed()


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	emit_changed()


func next_floor() -> void:
	floor += 1
	emit_changed()


func can_select_map_node(node_id: String) -> bool:
	if node_id.is_empty():
		return false
	if not map_reachable_node_ids.has(node_id):
		return false
	return not map_visited_node_ids.has(node_id)


func enter_map_node(node_id: String) -> bool:
	if not can_select_map_node(node_id):
		return false

	var node := get_map_node(node_id)
	if node == null:
		return false

	map_current_node_id = node_id
	map_visited_node_ids.append(node_id)
	map_reachable_node_ids = node.next_node_ids.duplicate()
	emit_changed()
	return true


func get_map_node(node_id: String) -> MapNodeData:
	if map_graph == null:
		return null
	return map_graph.get_node(node_id)


func _init_map_progression() -> void:
	map_graph = MAP_GENERATOR_SCRIPT.create_act1_seed_graph(seed)
	map_current_node_id = ""
	map_visited_node_ids = PackedStringArray()
	map_reachable_node_ids = map_graph.get_start_node_ids() if map_graph != null else PackedStringArray()


func _on_player_stats_changed() -> void:
	emit_changed()
