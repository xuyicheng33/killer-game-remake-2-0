class_name RunState
extends Resource

const MAP_GENERATOR_SCRIPT := preload("res://runtime/modules/map_event/map_generator.gd")

@export var character_id: String = "warrior"
@export var run_seed: int = 0
@export var act: int = 1
@export var current_floor: int = 0
@export var gold: int = 99
@export var relic_capacity: int = 6
@export var potion_capacity: int = 3
@export var map_current_node_id: String = ""
@export var map_reachable_node_ids: PackedStringArray = PackedStringArray()
@export var map_visited_node_ids: PackedStringArray = PackedStringArray()
@export var relics: Array[RelicData] = []
@export var potions: Array[PotionData] = []
@export var card_removal_count: int = 0
@export var run_start_relics_applied: bool = false

var player_stats: CharacterStats
var map_graph: MapGraphData


func init_with_character(base_stats: CharacterStats, p_run_seed: int, id: String = "warrior") -> void:
	character_id = id
	run_seed = p_run_seed
	act = 1
	current_floor = 0
	gold = 99
	relics.clear()
	potions.clear()
	run_start_relics_applied = false

	if player_stats != null and player_stats.stats_changed.is_connected(_on_player_stats_changed):
		player_stats.stats_changed.disconnect(_on_player_stats_changed)

	var source_stats := base_stats if base_stats != null else _build_fallback_character_stats()
	var instance_variant: Variant = source_stats.create_instance()
	if instance_variant is CharacterStats:
		player_stats = instance_variant
	else:
		player_stats = _build_fallback_character_stats()
	player_stats.stats_changed.connect(_on_player_stats_changed)

	_init_map_progression()
	emit_changed()


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	emit_changed()


func spend_gold(amount: int) -> bool:
	if amount <= 0:
		return true
	if gold < amount:
		return false
	gold -= amount
	emit_changed()
	return true


func add_relic(relic: RelicData) -> bool:
	if relic == null:
		return false
	var relic_id: String = relic.id.strip_edges()
	if relic_id.is_empty():
		return false
	if relics.size() >= relic_capacity:
		return false

	for existing_variant in relics:
		if not (existing_variant is RelicData):
			continue
		var existing: RelicData = existing_variant as RelicData
		if existing != null and existing.id == relic_id:
			return false

	relics.append(relic.duplicate(true))
	emit_changed()
	return true


func add_potion(potion: PotionData) -> bool:
	if potion == null:
		return false
	if potions.size() >= potion_capacity:
		return false
	potions.append(potion.duplicate(true))
	emit_changed()
	return true




func next_floor() -> void:
	current_floor += 1
	emit_changed()


func can_select_map_node(node_id: String) -> bool:
	if node_id.is_empty():
		return false
	if not map_reachable_node_ids.has(node_id):
		return false
	return not map_visited_node_ids.has(node_id)


func enter_map_node(node_id: String) -> bool:
	if not can_select_map_node(node_id):
		return false

	var node := get_map_node(node_id)
	if node == null:
		return false

	map_current_node_id = node_id
	map_visited_node_ids.append(node_id)
	map_reachable_node_ids = node.next_node_ids.duplicate()
	emit_changed()
	return true


func get_map_node(node_id: String) -> MapNodeData:
	if map_graph == null:
		return null
	return map_graph.get_node(node_id)


func get_deck_cards() -> Array[Card]:
	if player_stats == null or player_stats.deck == null:
		return []
	return player_stats.deck.cards


func add_card_to_deck(card: Card) -> bool:
	if card == null:
		return false
	if player_stats == null or player_stats.deck == null:
		return false
	player_stats.deck.add_card(card.duplicate(true))
	emit_changed()
	return true


func remove_card_from_deck_at(index: int) -> Card:
	if player_stats == null or player_stats.deck == null:
		return null
	var cards := player_stats.deck.cards
	if index < 0 or index >= cards.size():
		return null

	var removed := cards[index] as Card
	cards.remove_at(index)
	player_stats.deck.card_pile_size_changed.emit(cards.size())
	emit_changed()
	return removed


func upgrade_card_in_deck_at(index: int) -> bool:
	if player_stats == null or player_stats.deck == null:
		return false
	var cards := player_stats.deck.cards
	if index < 0 or index >= cards.size():
		return false

	var base_card := cards[index] as Card
	if base_card == null:
		return false

	var upgraded := base_card.duplicate(true) as Card
	if upgraded == null:
		return false

	# 优先使用 upgrade_to 字段（数据驱动）
	var target_id := base_card.upgrade_to.strip_edges()
	if not target_id.is_empty():
		upgraded.id = target_id
		upgraded.upgrade_to = ""
	else:
		# 回退到硬编码行为（向后兼容）
		upgraded.id = "%s+" % upgraded.id

	if upgraded.cost > 0:
		upgraded.cost -= 1
	if upgraded.tooltip_text.length() > 0:
		upgraded.tooltip_text += "\n[升级] 本卡费用-1（最低0）。"
	else:
		upgraded.tooltip_text = "[升级] 本卡费用-1（最低0）。"

	cards[index] = upgraded
	player_stats.deck.card_pile_size_changed.emit(cards.size())
	emit_changed()
	return true


func increment_card_removal_count() -> void:
	card_removal_count += 1
	emit_changed()


func heal_player(amount: int) -> void:
	if player_stats == null:
		return
	player_stats.heal(maxi(0, amount))
	emit_changed()


func damage_player(amount: int) -> void:
	if player_stats == null:
		return
	player_stats.take_damage(maxi(0, amount))
	emit_changed()


func increase_max_health(amount: int) -> void:
	if player_stats == null:
		return
	var delta := maxi(0, amount)
	if delta <= 0:
		return
	player_stats.max_health += delta
	player_stats.heal(delta)
	player_stats.stats_changed.emit()
	emit_changed()



func _init_map_progression() -> void:
	map_graph = MAP_GENERATOR_SCRIPT.create_act1_seed_graph(run_seed)
	map_current_node_id = ""
	map_visited_node_ids = PackedStringArray()
	map_reachable_node_ids = map_graph.get_start_node_ids() if map_graph != null else PackedStringArray()


func _on_player_stats_changed() -> void:
	emit_changed()


func _build_fallback_character_stats() -> CharacterStats:
	var stats := CharacterStats.new()
	stats.max_health = 1
	stats.health = 1
	stats.max_mana = 3
	stats.cards_per_turn = 5
	stats.starting_deck = CardPile.new()
	stats.deck = CardPile.new()
	stats.draw_pile = CardPile.new()
	stats.discard = CardPile.new()
	return stats
