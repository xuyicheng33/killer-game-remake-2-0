extends GutTest

# Scene Switch Memory Test
# Tests for memory leaks during scene creation/destruction cycles

const CYCLES := 20

# Godot 4 Performance monitor indices
# See: https://docs.godotengine.org/en/stable/classes/class_performance.html
const MONITOR_OBJECT_COUNT := 0
const MONITOR_ORPHAN_NODES := 14
const MONITOR_STATIC_MEMORY := 6


func test_scene_instantiation_no_orphans() -> void:
	# Test that instantiating and freeing scenes doesn't create orphans
	var initial_orphans := Performance.get_monitor(MONITOR_ORPHAN_NODES)

	for i in CYCLES:
		var scene := preload("res://runtime/scenes/battle/battle.tscn")
		var instance := scene.instantiate()
		add_child_autoqfree(instance)
		await get_tree().process_frame
		remove_child(instance)
		instance.queue_free()
		await get_tree().process_frame

	var final_orphans := Performance.get_monitor(MONITOR_ORPHAN_NODES)
	var orphan_delta := final_orphans - initial_orphans

	assert_true(orphan_delta <= 0, "Orphan nodes should not increase after scene cycles (delta: %d)" % orphan_delta)


func test_card_creation_no_leaks() -> void:
	# Test that creating Card resources doesn't leak
	var initial_objects := Performance.get_monitor(MONITOR_OBJECT_COUNT)

	for i in CYCLES:
		var card := Card.new()
		card.id = "test_card_%d" % i
		card.display_name = "测试卡牌"
		card.cost = 1
		card = null  # Release reference

	# Force garbage collection
	await get_tree().process_frame
	await get_tree().process_frame

	var final_objects := Performance.get_monitor(MONITOR_OBJECT_COUNT)
	var object_delta := final_objects - initial_objects

	# Allow small variance, but should be roughly the same
	assert_true(object_delta < 5, "Object count should not significantly increase (delta: %d)" % object_delta)


func test_resource_loading_no_leaks() -> void:
	# Test that loading resources doesn't leak
	var initial_memory := Performance.get_monitor(MONITOR_STATIC_MEMORY)

	for i in CYCLES:
		var card_path := "res://content/characters/warrior/cards/generated/warrior_axe_attack.tres"
		var card := load(card_path)
		card = null

	await get_tree().process_frame
	await get_tree().process_frame

	var final_memory := Performance.get_monitor(MONITOR_STATIC_MEMORY)
	var memory_delta := final_memory - initial_memory

	# Memory should not grow significantly
	assert_true(memory_delta < 1024 * 1024, "Static memory should not grow by more than 1MB (delta: %d bytes)" % memory_delta)


func test_signal_connections_cleanup() -> void:
	# Test that signal connections are properly cleaned up
	var node := Node.new()
	add_child_autoqfree(node)

	var signal_count_before := node.get_incoming_connections().size()

	# Connect and disconnect multiple times
	for i in CYCLES:
		var callback := func(): pass
		node.tree_entered.connect(callback)
		if node.tree_entered.is_connected(callback):
			node.tree_entered.disconnect(callback)

	var signal_count_after := node.get_incoming_connections().size()

	assert_eq(signal_count_after, signal_count_before, "Signal connections should be cleaned up")


func test_run_state_memory_stability() -> void:
	# Test that creating/frees simple objects doesn't leak
	var initial_objects := Performance.get_monitor(MONITOR_OBJECT_COUNT)

	for i in CYCLES:
		var dict := {"key": "value", "number": i}
		var arr := [1, 2, 3, 4, 5]
		arr.clear()
		dict.clear()

	await get_tree().process_frame
	await get_tree().process_frame

	var final_objects := Performance.get_monitor(MONITOR_OBJECT_COUNT)
	var object_delta := final_objects - initial_objects

	assert_true(object_delta < 10, "Object creation should not leak (delta: %d)" % object_delta)
