extends GutTest

const ENEMY_SPAWN_SERVICE_SCRIPT := preload("res://runtime/modules/battle_loop/enemy_spawn_service.gd")
const BATTLE_PARTICIPANT_RESOLVER_SCRIPT := preload("res://runtime/modules/relic_potion/battle_participant_resolver.gd")
const ENEMY_SCENE := preload("res://runtime/scenes/enemy/enemy.tscn")


class SessionPortDouble:
	extends RefCounted

	var player_value: Variant = null
	var enemies_value: Variant = []
	var battle_context: BattleContext = null

	func resolve_player() -> Variant:
		return player_value

	func resolve_enemies() -> Variant:
		return enemies_value


func test_enemy_spawn_service_rejects_null_enemy_scene() -> void:
	var service = ENEMY_SPAWN_SERVICE_SCRIPT.new()
	var enemy_handler := Node2D.new()
	get_tree().root.add_child(enemy_handler)

	var spawned := service.spawn_enemies(
		enemy_handler,
		RefCounted.new(),
		"act1_crab_single",
		1280.0,
		null
	)

	assert_eq(spawned.size(), 0, "enemy_scene 为空时应返回空数组")
	assert_push_error("enemy_scene is null", "enemy_scene 为空时应输出 push_error")

	if is_instance_valid(enemy_handler):
		enemy_handler.free()


func test_enemy_spawn_service_collects_only_enemies_group_nodes() -> void:
	var service = ENEMY_SPAWN_SERVICE_SCRIPT.new()
	var enemy_handler := Node2D.new()

	var enemy_node := Node2D.new()
	enemy_node.name = "EnemyCandidate"
	enemy_node.add_to_group("enemies")
	enemy_handler.add_child(enemy_node)

	var non_enemy_node := Node2D.new()
	non_enemy_node.name = "Decoration"
	enemy_handler.add_child(non_enemy_node)

	var enemies := service.collect_battle_enemies(enemy_handler)

	assert_eq(enemies.size(), 1, "仅应收集 enemies 组内节点")
	if enemies.size() > 0:
		assert_eq(enemies[0], enemy_node, "应返回 enemies 组节点")

	enemy_handler.free()


func test_battle_participant_resolver_prefers_session_port_player_in_group() -> void:
	var resolver = BATTLE_PARTICIPANT_RESOLVER_SCRIPT.new()
	var session_port := SessionPortDouble.new()

	var port_player := Node2D.new()
	port_player.add_to_group("player")
	session_port.player_value = port_player

	var resolved := resolver.resolve_player(session_port)
	assert_eq(resolved, port_player, "session_port 返回 player 组节点时应直接采用")

	if is_instance_valid(port_player):
		port_player.free()


func test_battle_participant_resolver_falls_back_to_scene_tree_player_group() -> void:
	var resolver = BATTLE_PARTICIPANT_RESOLVER_SCRIPT.new()
	var session_port := SessionPortDouble.new()
	session_port.player_value = Node2D.new()

	var fallback_player := Node2D.new()
	fallback_player.add_to_group("player")
	get_tree().root.add_child(fallback_player)

	var resolved := resolver.resolve_player(session_port)
	assert_eq(resolved, fallback_player, "session_port 非 player 节点时应回退到场景树 player 组")

	if is_instance_valid(session_port.player_value):
		(session_port.player_value as Node).free()
	if is_instance_valid(fallback_player):
		fallback_player.free()


func test_enemy_spawn_service_sets_battle_context_on_spawned_nodes() -> void:
	var service = ENEMY_SPAWN_SERVICE_SCRIPT.new()
	var enemy_handler := Node2D.new()
	get_tree().root.add_child(enemy_handler)

	var battle_context := RefCounted.new()
	var spawned := service.spawn_enemies(
		enemy_handler,
		battle_context,
		"act1_crab_single",
		1280.0,
		ENEMY_SCENE
	)

	assert_gt(spawned.size(), 0, "合法遭遇应生成至少一个敌人")
	for enemy_node in spawned:
		assert_true(enemy_node.is_in_group("enemies"), "生成节点应属于 enemies 组")
		assert_eq(enemy_node.get("battle_context"), battle_context, "生成节点应注入 battle_context")

	if is_instance_valid(enemy_handler):
		enemy_handler.free()


func test_battle_participant_resolver_falls_back_to_enemies_group_on_invalid_port_payload() -> void:
	var resolver = BATTLE_PARTICIPANT_RESOLVER_SCRIPT.new()
	var session_port := SessionPortDouble.new()
	session_port.enemies_value = "invalid_payload"

	var fallback_enemy := Node2D.new()
	fallback_enemy.add_to_group("enemies")
	get_tree().root.add_child(fallback_enemy)

	var non_enemy := Node2D.new()
	get_tree().root.add_child(non_enemy)

	var resolved_enemies := resolver.resolve_enemies(session_port)
	assert_eq(resolved_enemies.size(), 1, "无效 payload 时应回退并仅返回 enemies 组")
	if resolved_enemies.size() > 0:
		assert_eq(resolved_enemies[0], fallback_enemy, "回退结果应命中 enemies 组节点")

	if is_instance_valid(fallback_enemy):
		fallback_enemy.free()
	if is_instance_valid(non_enemy):
		non_enemy.free()
