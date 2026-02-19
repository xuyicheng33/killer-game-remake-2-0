class_name GameApp
extends Node

const MAP_SCREEN_SCENE := preload("res://runtime/scenes/map/map_screen.tscn")
const BATTLE_SCENE := preload("res://runtime/scenes/battle/battle.tscn")
const REWARD_SCREEN_SCENE := preload("res://runtime/scenes/reward/reward_screen.tscn")
const REST_SCREEN_SCENE := preload("res://runtime/scenes/map/rest_screen.tscn")
const SHOP_SCREEN_SCENE := preload("res://runtime/scenes/shop/shop_screen.tscn")
const EVENT_SCREEN_SCENE := preload("res://runtime/scenes/events/event_screen.tscn")
const CHARACTER_REGISTRY_SCRIPT := preload("res://runtime/modules/run_meta/character_registry.gd")
const RELIC_POTION_SYSTEM_SCRIPT := preload("res://runtime/modules/relic_potion/relic_potion_system.gd")
const RUN_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/run_flow_service.gd")

@onready var scene_host: Node = %SceneHost
@onready var relic_potion_ui: RelicPotionUI = %RelicPotionUI
@onready var game_over_panel: Panel = %GameOverPanel
@onready var game_over_text: Label = %GameOverText
@onready var restart_button: Button = %RestartButton

var run_state: RunState
var relic_potion_system: RelicPotionSystem
var run_flow_service: RunFlowService


func _ready() -> void:
	add_to_group("app")
	run_flow_service = RUN_FLOW_SERVICE_SCRIPT.new() as RunFlowService

	relic_potion_system = RELIC_POTION_SYSTEM_SCRIPT.new() as RelicPotionSystem
	add_child(relic_potion_system)
	relic_potion_ui.relic_potion_system = relic_potion_system

	_connect_signals()
	if not _try_load_saved_run():
		_start_new_run()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	if not Events.battle_finished.is_connected(_on_battle_finished):
		Events.battle_finished.connect(_on_battle_finished)
	if not restart_button.pressed.is_connected(_start_new_run):
		restart_button.pressed.connect(_start_new_run)


func _disconnect_signals() -> void:
	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if Events.battle_finished.is_connected(_on_battle_finished):
		Events.battle_finished.disconnect(_on_battle_finished)
	if restart_button.pressed.is_connected(_start_new_run):
		restart_button.pressed.disconnect(_start_new_run)


func _start_new_run() -> void:
	_clear_scene_host()
	game_over_panel.hide()
	get_tree().paused = false

	var hero_template: CharacterStats = CHARACTER_REGISTRY_SCRIPT.get_selected_character_template()
	if hero_template == null:
		push_error("无法加载角色模板")
		return

	var result := run_flow_service.lifecycle_service.start_new_run(hero_template, CHARACTER_REGISTRY_SCRIPT.get_selected_character_id())
	if not bool(result.get("ok", false)):
		push_error("新局初始化失败")
		return

	run_state = _extract_run_state(result)
	if run_state == null:
		push_error("新局初始化失败：返回结果中缺少有效的 RunState")
		return
	run_flow_service.reset_flow_context()
	relic_potion_system.bind_run_state(run_state)
	relic_potion_ui.run_state = run_state
	run_flow_service.lifecycle_service.update_repro_progress(run_state)

	_open_map()


func _open_map() -> void:
	_clear_scene_host()
	var map_screen := MAP_SCREEN_SCENE.instantiate() as MapScreen
	map_screen.run_state = run_state
	map_screen.set_map_graph(run_state.map_graph)
	map_screen.node_selected.connect(_on_map_node_selected)
	map_screen.restart_requested.connect(_start_new_run)
	scene_host.add_child(map_screen)
	_save_checkpoint("map")


func _on_map_node_selected(node: MapNodeData) -> void:
	var command_result := run_flow_service.map_flow_service.enter_map_node(run_state, node)
	if not bool(command_result.get("accepted", false)):
		return

	run_flow_service.apply_map_node_context(command_result, node.type)
	run_flow_service.lifecycle_service.log_node_enter(
		str(command_result.get("node_id", node.id)),
		int(run_flow_service.get_pending_node_type())
	)
	_dispatch_next_route(command_result)


func _open_battle(encounter_id: String = "") -> void:
	_clear_scene_host()
	relic_potion_system.start_battle()
	var battle_scene := BATTLE_SCENE.instantiate()
	battle_scene.set("runtime_stats", run_state.player_stats)
	battle_scene.set("encounter_id", encounter_id)
	scene_host.add_child(battle_scene)


func _on_battle_finished(result: int) -> void:
	relic_potion_system.end_battle()
	_clear_scene_host()

	var command_result := run_flow_service.battle_flow_service.resolve_battle_completion(
		run_state,
		result == BattleOverPanel.Type.WIN,
		run_flow_service.get_pending_reward_gold()
	)
	_dispatch_next_route(command_result)


func _open_reward(reward_gold: int) -> void:
	_clear_scene_host()
	var reward_screen := REWARD_SCREEN_SCENE.instantiate() as RewardScreen
	reward_screen.run_state = run_state
	reward_screen.reward_gold = reward_gold
	reward_screen.reward_completed.connect(_on_reward_completed)
	scene_host.add_child(reward_screen)


func _on_reward_completed(bundle: RewardBundle, chosen_card: Card) -> void:
	var command_result := run_flow_service.battle_flow_service.apply_battle_reward(run_state, bundle, chosen_card)
	var reward_log := str(command_result.get("reward_log", ""))
	if reward_log.length() > 0:
		relic_potion_system.push_external_log("战斗奖励：%s" % reward_log)
	_dispatch_next_route(command_result)


func _open_rest_screen() -> void:
	_clear_scene_host()
	var rest_screen := REST_SCREEN_SCENE.instantiate() as RestScreen
	rest_screen.run_state = run_state
	rest_screen.rest_completed.connect(_on_rest_completed)
	scene_host.add_child(rest_screen)


func _on_rest_completed() -> void:
	_on_non_battle_node_completed()


func _open_shop_screen() -> void:
	_clear_scene_host()
	relic_potion_system.on_shop_enter()
	var shop_screen := SHOP_SCREEN_SCENE.instantiate() as ShopScreen
	shop_screen.run_state = run_state
	shop_screen.shop_completed.connect(_on_shop_completed)
	scene_host.add_child(shop_screen)


func _on_shop_completed() -> void:
	_on_non_battle_node_completed()


func _open_event_screen() -> void:
	_clear_scene_host()
	var event_screen := EVENT_SCREEN_SCENE.instantiate() as EventScreen
	event_screen.run_state = run_state
	event_screen.event_completed.connect(_on_event_completed)
	scene_host.add_child(event_screen)


func _on_event_completed() -> void:
	_on_non_battle_node_completed()


func _on_non_battle_node_completed() -> void:
	var command_result := run_flow_service.map_flow_service.resolve_non_battle_completion(
		run_state,
		run_flow_service.get_pending_node_type()
	)
	var bonus_log := str(command_result.get("bonus_log", ""))
	if bonus_log.length() > 0:
		relic_potion_system.push_external_log(bonus_log)
	_dispatch_next_route(command_result)


func _dispatch_next_route(command_result: Dictionary) -> void:
	var next_route := str(command_result.get("next_route", RunRouteDispatcher.ROUTE_MAP))
	run_flow_service.apply_route_context(command_result)
	match next_route:
		RunRouteDispatcher.ROUTE_BATTLE:
			var enc_id := str(command_result.get("encounter_id", ""))
			_open_battle(enc_id)
		RunRouteDispatcher.ROUTE_REWARD:
			_open_reward(run_flow_service.reward_gold_for(command_result))
		RunRouteDispatcher.ROUTE_REST:
			_open_rest_screen()
		RunRouteDispatcher.ROUTE_SHOP:
			_open_shop_screen()
		RunRouteDispatcher.ROUTE_EVENT:
			_open_event_screen()
		RunRouteDispatcher.ROUTE_GAME_OVER:
			game_over_panel.show()
			game_over_text.text = str(command_result.get("game_over_text", "本次远征失败"))
		_:
			_open_map()


func _clear_scene_host() -> void:
	for child in scene_host.get_children():
		child.queue_free()


func _try_load_saved_run() -> bool:
	var hero_template: CharacterStats = CHARACTER_REGISTRY_SCRIPT.get_selected_character_template()
	if hero_template == null:
		push_error("无法加载角色模板")
		return false

	var result := run_flow_service.lifecycle_service.try_load_saved_run(hero_template)
	if not bool(result.get("ok", false)):
		push_warning("[save] %s" % str(result.get("message", "读档失败。")))
		return false

	_clear_scene_host()
	game_over_panel.hide()
	get_tree().paused = false

	run_state = _extract_run_state(result)
	if run_state == null:
		push_warning("[save] 读档失败：返回结果中缺少有效的 RunState。")
		return false
	run_flow_service.reset_flow_context()
	relic_potion_system.bind_run_state(run_state)
	relic_potion_ui.run_state = run_state
	_open_map()
	relic_potion_system.push_external_log("继续游戏：层数 %d，金币 %d" % [run_state.floor + 1, run_state.gold])
	return true


func _save_checkpoint(tag: String) -> void:
	var result := run_flow_service.lifecycle_service.save_checkpoint(run_state, tag)
	if not bool(result.get("ok", false)):
		push_warning("[save] %s" % str(result.get("message", "存档失败。")))
		return

	if tag.length() > 0:
		push_warning("[save] checkpoint: %s" % tag)


func _extract_run_state(result: Dictionary) -> RunState:
	var run_state_variant: Variant = result.get("run_state")
	if run_state_variant is RunState:
		return run_state_variant
	return null


func _on_viewport_resized() -> void:
	_apply_overlay_layout()


func _apply_overlay_layout() -> void:
	if not is_node_ready():
		return

	var viewport := get_viewport()
	if viewport == null:
		return

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var panel_width := clampf(viewport_size.x * 0.55, 520.0, 980.0)
	var panel_height := clampf(viewport_size.y * 0.55, 320.0, 640.0)

	game_over_panel.offset_left = -panel_width * 0.5
	game_over_panel.offset_top = -panel_height * 0.5
	game_over_panel.offset_right = panel_width * 0.5
	game_over_panel.offset_bottom = panel_height * 0.5
