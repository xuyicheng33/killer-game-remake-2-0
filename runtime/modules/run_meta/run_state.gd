class_name RunState
extends Resource

const MAP_GENERATOR_SCRIPT := preload("res://runtime/modules/map_event/map_generator.gd")

@export var character_id: String = "warrior"
@export var seed: int = 0
@export var act: int = 1
@export var floor: int = 0
@export var gold: int = 99
@export var relic_capacity: int = 6
@export var potion_capacity: int = 2
@export var map_current_node_id: String = ""
@export var map_reachable_node_ids: PackedStringArray = PackedStringArray()
@export var map_visited_node_ids: PackedStringArray = PackedStringArray()
@export var relics: Array[RelicData] = []
@export var potions: Array[PotionData] = []

var player_stats: CharacterStats
var map_graph: MapGraphData


func init_with_character(base_stats: CharacterStats, run_seed: int, id: String = "warrior") -> void:
	character_id = id
	seed = run_seed
	act = 1
	floor = 0
	gold = 99
	relics.clear()
	potions.clear()

	player_stats = base_stats.create_instance()
	if not player_stats.stats_changed.is_connected(_on_player_stats_changed):
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
	if relics.size() >= relic_capacity:
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


func use_potion_at(index: int) -> String:
	if index < 0 or index >= potions.size():
		return "药水使用失败：索引越界。"

	var potion := potions[index] as PotionData
	if potion == null:
		potions.remove_at(index)
		emit_changed()
		return "药水使用失败：无效药水。"

	var result := _apply_potion_effect(potion)
	potions.remove_at(index)
	emit_changed()
	return result


func next_floor() -> void:
	floor += 1
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


func _apply_potion_effect(potion: PotionData) -> String:
	var value := maxi(0, potion.value)
	match potion.effect_type:
		PotionData.EffectType.HEAL:
			heal_player(value)
			return "使用 %s：恢复 %d 生命" % [potion.title, value]
		PotionData.EffectType.GOLD:
			add_gold(value)
			return "使用 %s：获得 %d 金币" % [potion.title, value]
		PotionData.EffectType.BLOCK:
			if player_stats != null:
				player_stats.block += value
			return "使用 %s：获得 %d 格挡" % [potion.title, value]
		_:
			return "使用 %s：无效果" % potion.title


func _init_map_progression() -> void:
	map_graph = MAP_GENERATOR_SCRIPT.create_act1_seed_graph(seed)
	map_current_node_id = ""
	map_visited_node_ids = PackedStringArray()
	map_reachable_node_ids = map_graph.get_start_node_ids() if map_graph != null else PackedStringArray()


func _on_player_stats_changed() -> void:
	emit_changed()
