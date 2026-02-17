class_name Card
extends Resource

enum Type {ATTACK, SKILL, POWER}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

@export_group("Card Attributes")
@export var id: String
@export var type: Type
@export var target: Target
@export var cost: int

@export_group("Card Keywords")
@export var keyword_exhaust := false
@export var keyword_retain := false
@export var keyword_void := false
@export var keyword_ethereal := false
@export var keyword_x_cost := false

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var tooltip_text: String
@export var sound: AudioStream

var last_x_value := 0


func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY


func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
		
	var tree := targets[0].get_tree()
	
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("player") + tree.get_nodes_in_group("enemies")
		_:
			return []


func play(targets: Array[Node], char_stats: CharacterStats) -> void:
	if char_stats == null:
		return
	if not can_play(char_stats):
		return

	Events.card_played.emit(self)
	var mana_to_spend := cost
	if keyword_x_cost:
		mana_to_spend = maxi(char_stats.mana, 0)
		last_x_value = mana_to_spend
	else:
		last_x_value = 0

	char_stats.mana = maxi(char_stats.mana - mana_to_spend, 0)
	
	if is_single_targeted():
		apply_effects(targets)
	else:
		apply_effects(_get_targets(targets))


func can_play(char_stats: CharacterStats) -> bool:
	if char_stats == null:
		return false
	if not CardZonesModel.get_instance().is_player_action_window_open():
		return false
	if keyword_x_cost:
		return char_stats.mana > 0
	return char_stats.can_play_card(self)


func get_cost_label() -> String:
	if keyword_x_cost:
		return "X"
	return str(cost)


func is_ethereal_card() -> bool:
	return keyword_ethereal or keyword_void


func apply_effects(_targets: Array[Node]) -> void:
	pass
	
