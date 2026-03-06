class_name BattleTestFixture
extends RefCounted

const STATS_UI_SCENE := preload("res://runtime/scenes/ui/stats_ui.tscn")
const INTENT_UI_SCENE := preload("res://runtime/scenes/ui/intent_ui.tscn")

class FakePlayer:
	extends Player

	func _ready() -> void:
		pass

	func _exit_tree() -> void:
		pass

	func update_player() -> void:
		pass

	func update_stats() -> void:
		pass

	func take_damage(damage: int) -> void:
		if stats == null:
			return
		stats.take_damage(maxi(0, damage))
		if stats.health <= 0:
			Events.player_died.emit()


class FakeEnemy:
	extends Enemy

	func _ready() -> void:
		pass

	func _exit_tree() -> void:
		pass

	func update_enemy() -> void:
		pass

	func update_stats() -> void:
		pass

	func setup_ai() -> void:
		pass

	func take_damage(damage: int) -> void:
		if stats == null:
			return
		stats.take_damage(maxi(0, damage))
		if stats.health <= 0:
			Events.enemy_died.emit(self)

class PhaseMachineSpy:
	extends BattlePhaseStateMachine

	var transition_log: Array[int] = []

	func transition_to(next_phase: int) -> bool:
		transition_log.append(next_phase)
		return super.transition_to(next_phase)

	func get_transition_log() -> Array[int]:
		return transition_log

	func clear_log() -> void:
		transition_log.clear()


class SpyEffectStack:
	extends EffectStackEngine

	var enqueue_calls := 0

	func enqueue_effect(
		effect_name: String,
		targets: Array[Node],
		apply_callable: Callable,
		priority: int = 50,
		effect_type: EffectType = EffectType.SPECIAL,
		source: Node = null,
		value: int = 0,
		chain_depth: int = 0
	) -> void:
		enqueue_calls += 1
		super.enqueue_effect(
			effect_name,
			targets,
			apply_callable,
			priority,
			effect_type,
			source,
			value,
			chain_depth
		)


class TestBattleContext:
	extends BattleContext

	var _bound_stats: CharacterStats = null
	var _action_window_open := true
	var draw_calls: Array[int] = []
	var gain_mana_calls: Array[int] = []

	func _init(
		bound_player: Node,
		bound_enemies: Array[Node],
		bound_stack: EffectStackEngine = null,
		bound_stats: CharacterStats = null
	) -> void:
		super._init()
		var player_stats_variant = bound_player.get("stats") if bound_player != null and "stats" in bound_player else null
		_bound_stats = bound_stats if bound_stats != null else (player_stats_variant if player_stats_variant is CharacterStats else null)
		effect_stack = bound_stack if bound_stack != null else EffectStackEngine.new()
		buff_system = BuffSystem.new()
		bind_combatants(bound_player, bound_enemies)

	func get(property: StringName) -> Variant:
		match String(property):
			"effect_stack":
				return effect_stack
			"buff_system":
				return buff_system
			"player":
				return get_player()
			_:
				return null

	func draw_cards(amount: int) -> int:
		var draw_amount := maxi(0, amount)
		draw_calls.append(draw_amount)
		return draw_amount

	func gain_mana(amount: int) -> int:
		var gain_amount := maxi(0, amount)
		gain_mana_calls.append(gain_amount)
		if _bound_stats == null:
			return 0
		var before := _bound_stats.mana
		_bound_stats.mana = mini(_bound_stats.max_mana, before + gain_amount)
		return _bound_stats.mana - before

	func is_player_action_window_open() -> bool:
		return _action_window_open

	func set_player_action_window_open(open: bool) -> void:
		_action_window_open = open


func create_character_stats(
	max_health: int = 80,
	health: int = 60,
	max_mana: int = 3,
	mana: int = 3
) -> CharacterStats:
	var stats := CharacterStats.new()
	stats.max_health = max_health
	stats.health = health
	stats.max_mana = max_mana
	stats.mana = mana
	stats.starting_deck = CardPile.new()
	stats.deck = CardPile.new()
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()
	return stats


func create_enemy_stats(max_health: int = 50, health: int = 50) -> EnemyStats:
	var stats := EnemyStats.new()
	stats.max_health = max_health
	stats.health = health
	return stats


func create_player(stats: CharacterStats) -> Player:
	var player := FakePlayer.new()
	player.name = "TestPlayer"
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	player.add_child(sprite)
	var stats_ui := _create_stats_ui()
	stats_ui.name = "StatsUI"
	player.add_child(stats_ui)
	player.stats = stats
	if not player.is_in_group("player"):
		player.add_to_group("player")
	return player


func create_enemy(stats: EnemyStats) -> Enemy:
	var enemy := FakeEnemy.new()
	enemy.name = "TestEnemy"
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	enemy.add_child(sprite)
	var arrow := Sprite2D.new()
	arrow.name = "Arrow"
	enemy.add_child(arrow)
	var stats_ui := _create_stats_ui()
	stats_ui.name = "StatsUI"
	enemy.add_child(stats_ui)
	var intent_ui := _create_intent_ui()
	intent_ui.name = "IntentUI"
	enemy.add_child(intent_ui)
	enemy.stats = stats
	if not enemy.is_in_group("enemies"):
		enemy.add_to_group("enemies")
	return enemy


func _create_stats_ui() -> StatsUI:
	var ui_variant: Variant = STATS_UI_SCENE.instantiate()
	if ui_variant is StatsUI:
		return ui_variant as StatsUI
	return StatsUI.new()


func _create_intent_ui() -> IntentUI:
	var ui_variant: Variant = INTENT_UI_SCENE.instantiate()
	if ui_variant is IntentUI:
		return ui_variant as IntentUI
	return IntentUI.new()


func add_nodes_to_root(nodes: Array[Node]) -> void:
	var main_loop: MainLoop = Engine.get_main_loop()
	if not (main_loop is SceneTree):
		return
	var tree: SceneTree = main_loop as SceneTree
	var root: Node = tree.root
	for node in nodes:
		if node == null:
			continue
		if node.get_parent() == null:
			root.add_child(node)


func free_nodes(nodes: Array[Node]) -> void:
	for node in nodes:
		if node != null and is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()


func status_total(stats: Stats) -> int:
	if stats == null:
		return 0
	var total := 0
	var snapshot := stats.get_status_snapshot()
	for key in snapshot.keys():
		var value = snapshot.get(key, 0)
		if value is int:
			total += int(value)
	return total
