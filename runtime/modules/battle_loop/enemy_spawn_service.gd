class_name EnemySpawnService
extends RefCounted

const ENEMY_SCENE := preload("res://runtime/scenes/enemy/enemy.tscn")
const ENEMY_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/enemy_registry.gd")
const ENCOUNTER_REGISTRY_SCRIPT := preload("res://runtime/modules/enemy_intent/encounter_registry.gd")


func spawn_enemies(
	enemy_handler: Node,
	battle_context: RefCounted,
	encounter_id: String,
	viewport_width: float
) -> Array[Enemy]:
	if enemy_handler == null:
		return []

	_clear_existing_enemies(enemy_handler)

	var enemy_ids := _resolve_enemy_ids(encounter_id)
	if enemy_ids.is_empty():
		enemy_ids = ["crab", "bat"]

	var safe_viewport_width := viewport_width if viewport_width > 0.0 else 1280.0
	var enemy_count := enemy_ids.size()
	var start_x := safe_viewport_width * 0.6
	var spacing := safe_viewport_width * 0.12
	var base_y := 530.0

	for i in enemy_count:
		var enemy_id := enemy_ids[i]
		var enemy_stats: EnemyStats = ENEMY_REGISTRY_SCRIPT.get_enemy_stats(enemy_id)
		if enemy_stats == null:
			push_error("EnemySpawnService: failed to load enemy stats for '%s'" % enemy_id)
			continue

		var enemy: Enemy = ENEMY_SCENE.instantiate() as Enemy
		enemy.stats = enemy_stats
		enemy.battle_context = battle_context

		var offset_x := (i - (enemy_count - 1) / 2.0) * spacing
		# 视觉布局随机抖动，不影响游戏逻辑或种子一致性
		enemy.position = Vector2(start_x + offset_x, base_y + randf_range(-30, 30))
		enemy_handler.add_child(enemy)

	return collect_battle_enemies(enemy_handler)


func collect_battle_enemies(enemy_handler: Node) -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	if enemy_handler == null:
		return enemies
	for child in enemy_handler.get_children():
		if child is Enemy:
			enemies.append(child)
	return enemies


func _resolve_enemy_ids(encounter_id: String) -> Array[String]:
	var enemy_ids: Array[String] = []
	if encounter_id.is_empty():
		return enemy_ids

	var encounter := ENCOUNTER_REGISTRY_SCRIPT.get_encounter_by_id(encounter_id)
	enemy_ids = ENCOUNTER_REGISTRY_SCRIPT.get_enemy_ids_for_encounter(encounter)
	return enemy_ids


func _clear_existing_enemies(enemy_handler: Node) -> void:
	for child in enemy_handler.get_children():
		child.queue_free()
