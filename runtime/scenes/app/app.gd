class_name GameApp
extends Node

const MAIN_MENU_SCENE := preload("res://runtime/scenes/main_menu/main_menu.tscn")
const MAP_SCREEN_SCENE := preload("res://runtime/scenes/map/map_screen.tscn")
const BATTLE_SCENE := preload("res://runtime/scenes/battle/battle.tscn")
const REWARD_SCREEN_SCENE := preload("res://runtime/scenes/reward/reward_screen.tscn")
const REST_SCREEN_SCENE := preload("res://runtime/scenes/map/rest_screen.tscn")
const SHOP_SCREEN_SCENE := preload("res://runtime/scenes/shop/shop_screen.tscn")
const EVENT_SCREEN_SCENE := preload("res://runtime/scenes/events/event_screen.tscn")
const RELIC_POTION_SYSTEM_SCRIPT := preload("res://runtime/modules/relic_potion/relic_potion_system.gd")
const RUN_FLOW_SERVICE_SCRIPT := preload("res://runtime/modules/run_flow/run_flow_service.gd")
const APP_FLOW_ORCHESTRATOR_SCRIPT := preload("res://runtime/modules/run_flow/app_flow_orchestrator.gd")

@onready var scene_host: Node = %SceneHost
@onready var relic_potion_ui: RelicPotionUI = %RelicPotionUI
@onready var game_over_panel: Panel = %GameOverPanel
@onready var game_over_text: Label = %GameOverText
@onready var restart_button: Button = %RestartButton

var run_state: RunState
var relic_potion_system: RelicPotionSystem
var run_flow_service: RunFlowService
var app_flow_orchestrator
var _route_handlers: Dictionary = {}


func _ready() -> void:
	add_to_group("app")
	run_flow_service = RUN_FLOW_SERVICE_SCRIPT.new() as RunFlowService

	relic_potion_system = RELIC_POTION_SYSTEM_SCRIPT.new() as RelicPotionSystem
	add_child(relic_potion_system)
	relic_potion_ui.relic_potion_system = relic_potion_system
	app_flow_orchestrator = APP_FLOW_ORCHESTRATOR_SCRIPT.new(
		run_flow_service,
		relic_potion_system
	)
	_build_route_handlers()

	_connect_signals()
	_open_main_menu()


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


## 公开接口：开始新游戏（供测试和外部调用）
func start_new_game(character_id: String = "") -> void:
	_start_new_run(character_id)


## 公开接口：仅供测试打开战斗场景
func start_battle_for_test(encounter_id: String = "") -> void:
	_open_battle(encounter_id)


func _start_new_run(character_id: String = "") -> void:
	_reset_app_overlay_state()

	var result: Dictionary = app_flow_orchestrator.start_new_run(character_id)
	if not bool(result.get("ok", false)):
		push_error(str(result.get("message", "新局初始化失败。")))
		return

	run_state = _extract_run_state(result)
	if run_state == null:
		push_error("新局初始化失败：返回结果中缺少有效的 RunState")
		return
	relic_potion_ui.run_state = run_state

	_open_map()


func _open_main_menu() -> void:
	_reset_app_overlay_state()

	var main_menu: Control = MAIN_MENU_SCENE.instantiate()
	main_menu.new_game_requested.connect(_on_new_game_requested)
	main_menu.continue_game_requested.connect(_on_continue_game_requested)
	scene_host.add_child(main_menu)


func _on_new_game_requested(character_id: String) -> void:
	_start_new_run(character_id)


func _on_continue_game_requested() -> void:
	_reset_app_overlay_state()

	if not _try_load_saved_run():
		# 如果读档失败，返回主菜单
		_open_main_menu()


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
	var command_result: Dictionary = app_flow_orchestrator.enter_map_node(run_state, node)
	if not bool(command_result.get("accepted", false)):
		var error_text := str(command_result.get("error_text", ""))
		if error_text.length() > 0:
			push_warning("[map] %s" % error_text)
			app_flow_orchestrator.push_external_log("节点进入失败：%s" % error_text)
		return
	_dispatch_next_route(command_result)


func _open_battle(encounter_id: String = "") -> void:
	_clear_scene_host()
	var battle_scene := BATTLE_SCENE.instantiate()
	battle_scene.set("runtime_stats", run_state.player_stats)
	battle_scene.set("encounter_id", encounter_id)
	battle_scene.set("relic_potion_system", relic_potion_system)
	scene_host.add_child(battle_scene)


func _on_battle_finished(result: int) -> void:
	_clear_scene_host()
	var command_result: Dictionary = app_flow_orchestrator.resolve_battle_completion(run_state, result)
	_dispatch_next_route(command_result)


func _open_reward(reward_gold: int) -> void:
	_clear_scene_host()
	var reward_screen := REWARD_SCREEN_SCENE.instantiate() as RewardScreen
	reward_screen.run_state = run_state
	reward_screen.reward_gold = reward_gold
	reward_screen.reward_completed.connect(_on_reward_completed)
	scene_host.add_child(reward_screen)


func _on_reward_completed(bundle: RewardBundle, chosen_card: Card) -> void:
	var command_result: Dictionary = app_flow_orchestrator.apply_battle_reward(run_state, bundle, chosen_card)
	var reward_log := str(command_result.get("reward_log", ""))
	if reward_log.length() > 0:
		app_flow_orchestrator.push_external_log("战斗奖励：%s" % reward_log)
	_dispatch_next_route(command_result)


func _open_rest_screen() -> void:
	_open_run_state_screen(
		REST_SCREEN_SCENE,
		&"rest_completed",
		Callable(self, "_on_rest_completed")
	)


func _on_rest_completed() -> void:
	_on_non_battle_node_completed()


func _open_shop_screen() -> void:
	_open_run_state_screen(
		SHOP_SCREEN_SCENE,
		&"shop_completed",
		Callable(self, "_on_shop_completed"),
		Callable(self, "_notify_shop_enter")
	)


func _on_shop_completed() -> void:
	_on_non_battle_node_completed()


func _open_event_screen() -> void:
	_open_run_state_screen(
		EVENT_SCREEN_SCENE,
		&"event_completed",
		Callable(self, "_on_event_completed")
	)


func _on_event_completed() -> void:
	_on_non_battle_node_completed()


func _on_non_battle_node_completed() -> void:
	var command_result: Dictionary = app_flow_orchestrator.resolve_non_battle_completion(run_state)
	var bonus_log := str(command_result.get("bonus_log", ""))
	if bonus_log.length() > 0:
		app_flow_orchestrator.push_external_log(bonus_log)
	_dispatch_next_route(command_result)


func _dispatch_next_route(command_result: Dictionary) -> void:
	var next_route: String = app_flow_orchestrator.dispatch_next_route(command_result)
	var route_handler: Variant = _route_handlers.get(next_route, Callable())
	if route_handler is Callable:
		var callable_handler: Callable = route_handler as Callable
		if callable_handler.is_valid():
			callable_handler.call(command_result)
			return
	_open_map()


func _clear_scene_host() -> void:
	for child in scene_host.get_children():
		child.queue_free()


func _try_load_saved_run() -> bool:
	var result: Dictionary = app_flow_orchestrator.continue_saved_run()
	if not bool(result.get("ok", false)):
		push_warning("[save] %s" % str(result.get("message", "读档失败。")))
		return false

	_reset_app_overlay_state()

	run_state = _extract_run_state(result)
	if run_state == null:
		push_warning("[save] 读档失败：返回结果中缺少有效的 RunState。")
		return false
	relic_potion_ui.run_state = run_state
	_open_map()
	app_flow_orchestrator.push_external_log("继续游戏：层数 %d，金币 %d" % [run_state.floor + 1, run_state.gold])
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


func _notify_shop_enter() -> void:
	app_flow_orchestrator.on_shop_enter()


func _reset_app_overlay_state() -> void:
	_clear_scene_host()
	game_over_panel.hide()
	get_tree().paused = false


func _open_run_state_screen(
	scene: PackedScene,
	completed_signal: StringName,
	completed_handler: Callable,
	before_attach: Callable = Callable()
) -> Node:
	_clear_scene_host()
	if before_attach.is_valid():
		before_attach.call()

	var screen: Node = scene.instantiate()
	screen.set("run_state", run_state)
	if not completed_signal.is_empty() and screen.has_signal(completed_signal) and completed_handler.is_valid():
		screen.connect(completed_signal, completed_handler)
	scene_host.add_child(screen)
	return screen


func _build_route_handlers() -> void:
	_route_handlers[RunRouteDispatcher.ROUTE_BATTLE] = func(command_result: Dictionary) -> void:
		_open_battle(str(command_result.get("encounter_id", "")))

	_route_handlers[RunRouteDispatcher.ROUTE_REWARD] = func(command_result: Dictionary) -> void:
		_open_reward(app_flow_orchestrator.reward_gold_for(command_result))

	_route_handlers[RunRouteDispatcher.ROUTE_REST] = func(_command_result: Dictionary) -> void:
		_open_rest_screen()

	_route_handlers[RunRouteDispatcher.ROUTE_SHOP] = func(_command_result: Dictionary) -> void:
		_open_shop_screen()

	_route_handlers[RunRouteDispatcher.ROUTE_EVENT] = func(_command_result: Dictionary) -> void:
		_open_event_screen()

	_route_handlers[RunRouteDispatcher.ROUTE_GAME_OVER] = func(command_result: Dictionary) -> void:
		game_over_panel.show()
		game_over_text.text = str(command_result.get("game_over_text", "本次远征失败"))

	_route_handlers[RunRouteDispatcher.ROUTE_RUN_COMPLETE] = func(command_result: Dictionary) -> void:
		game_over_panel.show()
		game_over_text.text = str(command_result.get("run_complete_text", "恭喜通关！"))


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
