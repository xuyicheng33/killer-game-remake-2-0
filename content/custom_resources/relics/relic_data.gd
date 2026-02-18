class_name RelicData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var rarity: String = "common"

@export var on_battle_start_heal: int = 0
@export var on_card_played_gold: int = 0
@export var card_play_interval: int = 1
@export var on_player_hit_block: int = 0
@export var on_enemy_killed_gold: int = 0
@export var on_turn_start_block: int = 0
@export var on_turn_end_heal: int = 0
@export var shop_discount_percent: int = 0

