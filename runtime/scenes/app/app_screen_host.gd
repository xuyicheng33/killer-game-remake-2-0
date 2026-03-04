class_name AppScreenHost
extends RefCounted

var scene_host: Node


func _init(scene_host_node: Node) -> void:
	scene_host = scene_host_node


func clear() -> void:
	if scene_host == null:
		return
	for child in scene_host.get_children():
		child.queue_free()


func open_main_menu(
	main_menu_scene: PackedScene,
	on_new_game_requested: Callable,
	on_continue_game_requested: Callable
) -> Control:
	clear()
	var main_menu: Control = main_menu_scene.instantiate()
	if on_new_game_requested.is_valid():
		main_menu.connect("new_game_requested", on_new_game_requested)
	if on_continue_game_requested.is_valid():
		main_menu.connect("continue_game_requested", on_continue_game_requested)
	scene_host.add_child(main_menu)
	return main_menu


func open_map(
	map_scene: PackedScene,
	run_state: RunState,
	on_node_selected: Callable,
	on_restart_requested: Callable
) -> Node:
	clear()
	var map_screen := map_scene.instantiate() as MapScreen
	map_screen.set("run_state", run_state)
	map_screen.set_map_graph(run_state.map_graph)
	if on_node_selected.is_valid():
		map_screen.connect("node_selected", on_node_selected)
	if on_restart_requested.is_valid():
		map_screen.connect("restart_requested", on_restart_requested)
	scene_host.add_child(map_screen)
	return map_screen


func open_reward(
	reward_scene: PackedScene,
	run_state: RunState,
	reward_gold: int,
	on_reward_completed: Callable
) -> Node:
	clear()
	var reward_screen: Node = reward_scene.instantiate()
	reward_screen.set("run_state", run_state)
	reward_screen.set("reward_gold", reward_gold)
	if on_reward_completed.is_valid():
		reward_screen.connect("reward_completed", on_reward_completed)
	scene_host.add_child(reward_screen)
	return reward_screen


func open_run_state_screen(
	scene: PackedScene,
	run_state: RunState,
	completed_signal: StringName,
	completed_handler: Callable
) -> Node:
	clear()
	var screen: Node = scene.instantiate()
	screen.set("run_state", run_state)
	if not completed_signal.is_empty() and screen.has_signal(completed_signal) and completed_handler.is_valid():
		screen.connect(completed_signal, completed_handler)
	scene_host.add_child(screen)
	return screen
