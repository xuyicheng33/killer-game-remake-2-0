class_name EnemyHandler
extends Node2D


func _ready() -> void:
	_connect_signals()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not Events.enemy_action_completed.is_connected(_on_enemy_action_completed):
		Events.enemy_action_completed.connect(_on_enemy_action_completed)


func _disconnect_signals() -> void:
	if Events.enemy_action_completed.is_connected(_on_enemy_action_completed):
		Events.enemy_action_completed.disconnect(_on_enemy_action_completed)


func reset_enemy_actions() -> void:
	for enemy: Enemy in get_children():
		enemy.current_action = null
		enemy.update_action()


func start_turn() -> void:
	if get_child_count() == 0:
		return
	
	var first_child: Node = get_child(0)
	if not (first_child is Enemy):
		return
	var first_enemy: Enemy = first_child
	first_enemy.do_turn()


func _on_enemy_action_completed(enemy: Enemy) -> void:
	if enemy.get_index() == get_child_count() - 1:
		Events.enemy_turn_ended.emit()
		return

	var next_index := enemy.get_index() + 1
	if next_index < 0 or next_index >= get_child_count():
		Events.enemy_turn_ended.emit()
		return
	var next_child: Node = get_child(next_index)
	if not (next_child is Enemy):
		Events.enemy_turn_ended.emit()
		return
	var next_enemy: Enemy = next_child
	next_enemy.do_turn()
