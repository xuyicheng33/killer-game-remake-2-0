class_name GameApp
extends Node

const MAP_SCREEN_SCENE := preload("res://scenes/map/map_screen.tscn")
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const REWARD_SCREEN_SCENE := preload("res://scenes/reward/reward_screen.tscn")
const HERO_TEMPLATE := preload("res://characters/warrior/warrior.tres")
const REWARD_GENERATOR_SCRIPT := preload("res://modules/reward_economy/reward_generator.gd")

@onready var scene_host: Node = %SceneHost
@onready var game_over_panel: Panel = %GameOverPanel
@onready var game_over_text: Label = %GameOverText
@onready var restart_button: Button = %RestartButton

var run_state: RunState
var pending_reward_gold := 0


func _ready() -> void:
	Events.battle_finished.connect(_on_battle_finished)
	restart_button.pressed.connect(_start_new_run)
	_start_new_run()


func _start_new_run() -> void:
	_clear_scene_host()
	game_over_panel.hide()
	get_tree().paused = false

	run_state = RunState.new()
	var seed := int(Time.get_unix_time_from_system()) % 1000000007
	run_state.init_with_character(HERO_TEMPLATE, seed)

	_open_map()


func _open_map() -> void:
	_clear_scene_host()
	var map_screen := MAP_SCREEN_SCENE.instantiate() as MapScreen
	map_screen.run_state = run_state
	map_screen.set_nodes(MapGenerator.create_act1_seed_map(run_state.seed, run_state.floor))
	map_screen.node_selected.connect(_on_map_node_selected)
	scene_host.add_child(map_screen)


func _on_map_node_selected(node: MapNodeData) -> void:
	match node.type:
		MapNodeData.NodeType.BATTLE, MapNodeData.NodeType.ELITE:
			pending_reward_gold = node.reward_gold
			_open_battle()
		MapNodeData.NodeType.REST:
			_apply_rest_node()
		MapNodeData.NodeType.EVENT:
			_apply_event_node(node)
		_:
			_apply_placeholder_node()


func _open_battle() -> void:
	_clear_scene_host()
	var battle_scene := BATTLE_SCENE.instantiate()
	battle_scene.set("runtime_stats", run_state.player_stats)
	scene_host.add_child(battle_scene)


func _apply_rest_node() -> void:
	var recover := maxi(6, int(round(run_state.player_stats.max_health * 0.2)))
	run_state.player_stats.heal(recover)
	run_state.next_floor()
	_open_map()


func _apply_event_node(node: MapNodeData) -> void:
	run_state.add_gold(node.reward_gold)
	run_state.next_floor()
	_open_map()


func _apply_placeholder_node() -> void:
	run_state.next_floor()
	_open_map()


func _on_battle_finished(result: int) -> void:
	_clear_scene_host()

	if result == BattleOverPanel.Type.WIN:
		_open_reward()
		return

	game_over_panel.show()
	game_over_text.text = "本次远征失败\n到达层数：%d\n最终金币：%d" % [run_state.floor + 1, run_state.gold]


func _open_reward() -> void:
	_clear_scene_host()
	var reward_screen := REWARD_SCREEN_SCENE.instantiate() as RewardScreen
	reward_screen.run_state = run_state
	reward_screen.reward_gold = pending_reward_gold
	reward_screen.reward_completed.connect(_on_reward_completed)
	scene_host.add_child(reward_screen)


func _on_reward_completed(bundle: RewardBundle, chosen_card: Card) -> void:
	# Apply and return to map.
	REWARD_GENERATOR_SCRIPT.apply_post_battle_reward(run_state, bundle, chosen_card)
	_open_map()


func _clear_scene_host() -> void:
	for child in scene_host.get_children():
		child.queue_free()
