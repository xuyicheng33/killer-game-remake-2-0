extends "res://runtime/modules/relic_potion/relic_base.gd"


func _init(relic_data: RelicData = null) -> void:
	super(relic_data)


func on_battle_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_battle_start_heal > 0:
		system.dispatch_relic_effect("heal", data.on_battle_start_heal, data)
		system.push_external_log("%s 触发：战斗开始恢复 %d 生命" % [data.title, data.on_battle_start_heal])


func on_battle_end(system: Object, context: Dictionary) -> void:
	if data == null:
		return
	if data.on_battle_end_heal_per_kill > 0:
		var kills: int = int(context.get("kills", 0))
		if kills > 0:
			var heal_amount := kills * data.on_battle_end_heal_per_kill
			system.dispatch_relic_effect("heal", heal_amount, data)
			system.push_external_log("%s 触发：战斗结束击杀 %d 敌人，恢复 %d 生命" % [data.title, kills, heal_amount])


func on_turn_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_turn_start_block > 0:
		system.dispatch_relic_effect("add_block", data.on_turn_start_block, data)
		system.push_external_log("%s 触发：回合开始获得 %d 格挡" % [data.title, data.on_turn_start_block])
	if data.on_turn_start_energy > 0:
		system.dispatch_relic_effect("add_energy", data.on_turn_start_energy, data)
		system.push_external_log("%s 触发：回合开始获得 %d 能量" % [data.title, data.on_turn_start_energy])
	if data.on_turn_start_damage > 0:
		system.dispatch_relic_effect("take_damage", data.on_turn_start_damage, data)
		system.push_external_log("%s 触发：回合开始受到 %d 伤害" % [data.title, data.on_turn_start_damage])


func on_turn_end(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_turn_end_heal > 0:
		system.dispatch_relic_effect("heal", data.on_turn_end_heal, data)
		system.push_external_log("%s 触发：回合结束恢复 %d 生命" % [data.title, data.on_turn_end_heal])


func on_card_played(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_card_played_gold <= 0:
		return

	var interval := maxi(1, data.card_play_interval)
	if system.get_cards_played_in_battle() % interval != 0:
		return

	system.dispatch_relic_effect("add_gold", data.on_card_played_gold, data)
	system.push_external_log("%s 触发：出牌后获得 %d 金币" % [data.title, data.on_card_played_gold])


func on_damage_taken(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_player_hit_block > 0:
		system.dispatch_relic_effect("add_block", data.on_player_hit_block, data)
		system.push_external_log("%s 触发：受击后获得 %d 格挡" % [data.title, data.on_player_hit_block])


func on_block_applied(system: Object, context: Dictionary) -> void:
	if data == null:
		return
	var block_amount := int(context.get("amount", 0))
	if block_amount <= 0:
		return
	system.push_external_log("%s 触发：侦测到获得 %d 格挡" % [data.title, block_amount])


func on_enemy_killed(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_enemy_killed_gold > 0:
		system.dispatch_relic_effect("add_gold", data.on_enemy_killed_gold, data)
		system.push_external_log("%s 触发：击杀敌人获得 %d 金币" % [data.title, data.on_enemy_killed_gold])
	if data.on_enemy_killed_strength > 0:
		system.dispatch_relic_effect("add_strength", data.on_enemy_killed_strength, data)
		system.push_external_log("%s 触发：击杀敌人获得 %d 力量" % [data.title, data.on_enemy_killed_strength])
	if data.on_enemy_killed_damage > 0:
		system.dispatch_relic_effect("take_damage", data.on_enemy_killed_damage, data)
		system.push_external_log("%s 触发：击杀敌人受到 %d 伤害" % [data.title, data.on_enemy_killed_damage])
	if data.on_enemy_killed_draw > 0:
		system.dispatch_relic_effect("draw_cards", data.on_enemy_killed_draw, data)
		system.push_external_log("%s 触发：击杀敌人抽 %d 张牌" % [data.title, data.on_enemy_killed_draw])


func on_boss_killed(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_enemy_killed_gold > 0:
		system.dispatch_relic_effect("add_gold", data.on_enemy_killed_gold, data)
		system.push_external_log("%s 触发：击败 Boss 获得 %d 金币" % [data.title, data.on_enemy_killed_gold])


func on_shop_enter(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.shop_discount_percent > 0:
		system.push_external_log("%s 生效：商店折扣 %d%%" % [data.title, data.shop_discount_percent])


func on_run_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_run_start_gold > 0:
		system.dispatch_relic_effect("add_gold", data.on_run_start_gold, data)
		system.push_external_log("%s 触发：开局获得 %d 金币" % [data.title, data.on_run_start_gold])
	if data.on_run_start_max_health > 0:
		system.dispatch_relic_effect("increase_max_health", data.on_run_start_max_health, data)
		system.push_external_log("%s 触发：开局最大生命 +%d" % [data.title, data.on_run_start_max_health])
	if data.on_run_start_strength > 0:
		system.dispatch_relic_effect("add_strength", data.on_run_start_strength, data)
		system.push_external_log("%s 触发：开局获得 %d 力量" % [data.title, data.on_run_start_strength])


func on_attack_played(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_attack_played_strength <= 0:
		return
	
	var max_triggers: int = maxi(0, data.attack_play_strength_max)
	if max_triggers > 0:
		var current_count: int = system.get_relic_trigger_count(data.id, "attack_played")
		if current_count >= max_triggers:
			return
		system.increment_relic_trigger_count(data.id, "attack_played")
	
	system.dispatch_relic_effect("add_strength", data.on_attack_played_strength, data)
	system.push_external_log("%s 触发：打出攻击牌获得 %d 力量" % [data.title, data.on_attack_played_strength])
