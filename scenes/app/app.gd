class_name GameApp
extends Node

const MAP_SCREEN_SCENE := preload("res://scenes/map/map_screen.tscn")
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const REWARD_SCREEN_SCENE := preload("res://scenes/reward/reward_screen.tscn")
const REST_SCREEN_SCENE := preload("res://scenes/map/rest_screen.tscn")
const SHOP_SCREEN_SCENE := preload("res://scenes/shop/shop_screen.tscn")
const EVENT_SCREEN_SCENE := preload("res://scenes/events/event_screen.tscn")
const HERO_TEMPLATE := preload("res://characters/warrior/warrior.tres")
const REWARD_GENERATOR_SCRIPT := preload("res://modules/reward_economy/reward_generator.gd")
const RELIC_POTION_SYSTEM_SCRIPT := preload("res://modules/relic_potion/relic_potion_system.gd")

@onready var scene_host: Node = %SceneHost
@onready var relic_potion_ui: RelicPotionUI = %RelicPotionUI
@onready var game_over_panel: Panel = %GameOverPanel
@onready var game_over_text: Label = %GameOverText
@onready var restart_button: Button = %RestartButton

var run_state: RunState
var pending_reward_gold := 0
var pending_node_type: MapNodeData.NodeType = MapNodeData.NodeType.BATTLE
var relic_potion_system: RelicPotionSystem


func _ready() -> void:
	relic_potion_system = RELIC_POTION_SYSTEM_SCRIPT.new() as RelicPotionSystem
	add_child(relic_potion_system)
	relic_potion_ui.relic_potion_system = relic_potion_system

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
	relic_potion_system.bind_run_state(run_state)
	relic_potion_ui.run_state = run_state

	_open_map()


func _open_map() -> void:
	_clear_scene_host()
	var map_screen := MAP_SCREEN_SCENE.instantiate() as MapScreen
	map_screen.run_state = run_state
	map_screen.set_map_graph(run_state.map_graph)
	map_screen.node_selected.connect(_on_map_node_selected)
	scene_host.add_child(map_screen)


func _on_map_node_selected(node: MapNodeData) -> void:
	if not run_state.enter_map_node(node.id):
		return

	pending_node_type = node.type

	match node.type:
		MapNodeData.NodeType.BATTLE, MapNodeData.NodeType.ELITE, MapNodeData.NodeType.BOSS:
			pending_reward_gold = node.reward_gold
			_open_battle()
		MapNodeData.NodeType.REST:
			_open_rest_screen()
		MapNodeData.NodeType.SHOP:
			_open_shop_screen()
		MapNodeData.NodeType.EVENT:
			_open_event_screen()
		_:
			_apply_placeholder_node()


func _open_battle() -> void:
	_clear_scene_host()
	relic_potion_system.start_battle()
	var battle_scene := BATTLE_SCENE.instantiate()
	battle_scene.set("runtime_stats", run_state.player_stats)
	scene_host.add_child(battle_scene)


func _apply_placeholder_node() -> void:
	run_state.next_floor()
	_open_map()


func _on_battle_finished(result: int) -> void:
	relic_potion_system.end_battle()
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
	var reward_log := REWARD_GENERATOR_SCRIPT.apply_post_battle_reward(run_state, bundle, chosen_card)
	if reward_log.length() > 0:
		relic_potion_system.push_external_log("战后奖励：%s" % reward_log)
	_open_map()


func _open_rest_screen() -> void:
	_clear_scene_host()
	var rest_screen := REST_SCREEN_SCENE.instantiate() as RestScreen
	rest_screen.run_state = run_state
	rest_screen.rest_completed.connect(_on_rest_completed)
	scene_host.add_child(rest_screen)


func _on_rest_completed() -> void:
	_open_map()


func _open_shop_screen() -> void:
	_clear_scene_host()
	var shop_screen := SHOP_SCREEN_SCENE.instantiate() as ShopScreen
	shop_screen.run_state = run_state
	shop_screen.shop_completed.connect(_on_shop_completed)
	scene_host.add_child(shop_screen)


func _on_shop_completed() -> void:
	_apply_b3_node_bonus_if_needed()
	_open_map()


func _open_event_screen() -> void:
	_clear_scene_host()
	var event_screen := EVENT_SCREEN_SCENE.instantiate() as EventScreen
	event_screen.run_state = run_state
	event_screen.event_completed.connect(_on_event_completed)
	scene_host.add_child(event_screen)


func _on_event_completed() -> void:
	_apply_b3_node_bonus_if_needed()
	_open_map()


func _apply_b3_node_bonus_if_needed() -> void:
	var bonus := REWARD_GENERATOR_SCRIPT.generate_b3_bonus(pending_node_type)
	var bonus_log := REWARD_GENERATOR_SCRIPT.apply_b3_bonus(run_state, bonus)
	if bonus_log.length() > 0:
		relic_potion_system.push_external_log(bonus_log)


func _clear_scene_host() -> void:
	for child in scene_host.get_children():
		child.queue_free()
