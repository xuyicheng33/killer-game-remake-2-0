class_name RelicBase
extends RefCounted

# 触发器类型统一使用 RelicPotionSystem.TriggerType 枚举
# 例如: RelicPotionSystem.TriggerType.ON_BATTLE_START

var data: RelicData


func _init(relic_data: RelicData = null) -> void:
	data = relic_data


func handle_trigger(trigger_type: int, context: Dictionary, system: Object) -> void:
	match trigger_type:
		RelicPotionSystem.TriggerType.ON_BATTLE_START:
			on_battle_start(system, context)
		RelicPotionSystem.TriggerType.ON_BATTLE_END:
			on_battle_end(system, context)
		RelicPotionSystem.TriggerType.ON_TURN_START:
			on_turn_start(system, context)
		RelicPotionSystem.TriggerType.ON_TURN_END:
			on_turn_end(system, context)
		RelicPotionSystem.TriggerType.ON_CARD_PLAYED:
			on_card_played(system, context)
		RelicPotionSystem.TriggerType.ON_ATTACK_PLAYED:
			on_attack_played(system, context)
		RelicPotionSystem.TriggerType.ON_SKILL_PLAYED:
			on_skill_played(system, context)
		RelicPotionSystem.TriggerType.ON_DAMAGE_TAKEN:
			on_damage_taken(system, context)
		RelicPotionSystem.TriggerType.ON_BLOCK_APPLIED:
			on_block_applied(system, context)
		RelicPotionSystem.TriggerType.ON_ENEMY_KILLED:
			on_enemy_killed(system, context)
		RelicPotionSystem.TriggerType.ON_RUN_START:
			on_run_start(system, context)
		RelicPotionSystem.TriggerType.ON_SHOP_ENTER:
			on_shop_enter(system, context)
		RelicPotionSystem.TriggerType.ON_BOSS_KILLED:
			on_boss_killed(system, context)


func on_battle_start(_system: Object, _context: Dictionary) -> void:
	pass


func on_battle_end(_system: Object, _context: Dictionary) -> void:
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
