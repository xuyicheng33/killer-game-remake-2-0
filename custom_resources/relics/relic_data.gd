class_name RelicData
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export var on_battle_start_heal: int = 0
@export var on_card_played_gold: int = 0
@export var card_play_interval: int = 1
@export var on_player_hit_block: int = 0

