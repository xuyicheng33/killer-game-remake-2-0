class_name RelicBase
extends RefCounted

const TRIGGER_ON_BATTLE_START := 0
const TRIGGER_ON_TURN_START := 1
const TRIGGER_ON_TURN_END := 2
const TRIGGER_ON_CARD_PLAYED := 3
const TRIGGER_ON_ATTACK_PLAYED := 4
const TRIGGER_ON_SKILL_PLAYED := 5
const TRIGGER_ON_DAMAGE_TAKEN := 6
const TRIGGER_ON_BLOCK_APPLIED := 7
const TRIGGER_ON_ENEMY_KILLED := 8
const TRIGGER_ON_RUN_START := 9
const TRIGGER_ON_SHOP_ENTER := 10
const TRIGGER_ON_BOSS_KILLED := 11

var data: RelicData


func _init(relic_data: RelicData = null) -> void:
	data = relic_data


func handle_trigger(trigger_type: int, context: Dictionary, system: Object) -> void:
	match trigger_type:
		TRIGGER_ON_BATTLE_START:
			on_battle_start(system, context)
		TRIGGER_ON_TURN_START:
			on_turn_start(system, context)
		TRIGGER_ON_TURN_END:
			on_turn_end(system, context)
		TRIGGER_ON_CARD_PLAYED:
			on_card_played(system, context)
		TRIGGER_ON_ATTACK_PLAYED:
			on_attack_played(system, context)
		TRIGGER_ON_SKILL_PLAYED:
			on_skill_played(system, context)
		TRIGGER_ON_DAMAGE_TAKEN:
			on_damage_taken(system, context)
		TRIGGER_ON_BLOCK_APPLIED:
			on_block_applied(system, context)
		TRIGGER_ON_ENEMY_KILLED:
			on_enemy_killed(system, context)
		TRIGGER_ON_RUN_START:
			on_run_start(system, context)
		TRIGGER_ON_SHOP_ENTER:
			on_shop_enter(system, context)
		TRIGGER_ON_BOSS_KILLED:
			on_boss_killed(system, context)


func on_battle_start(_system: Object, _context: Dictionary) -> void:
	pass


func on_turn_start(_system: Object, _context: Dictionary) -> void:
	pass


func on_turn_end(_system: Object, _context: Dictionary) -> void:
	pass


func on_card_played(_system: Object, _context: Dictionary) -> void:
	pass


func on_attack_played(_system: Object, _context: Dictionary) -> void:
	pass


func on_skill_played(_system: Object, _context: Dictionary) -> void:
	pass


func on_damage_taken(_system: Object, _context: Dictionary) -> void:
	pass


func on_block_applied(_system: Object, _context: Dictionary) -> void:
	pass


func on_enemy_killed(_system: Object, _context: Dictionary) -> void:
	pass


func on_run_start(_system: Object, _context: Dictionary) -> void:
	pass


func on_shop_enter(_system: Object, _context: Dictionary) -> void:
	pass


func on_boss_killed(_system: Object, _context: Dictionary) -> void:
	pass
