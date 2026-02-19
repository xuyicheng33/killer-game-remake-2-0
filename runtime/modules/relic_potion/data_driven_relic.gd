extends "res://runtime/modules/relic_potion/relic_base.gd"


func on_battle_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_battle_start_heal > 0:
		system.dispatch_relic_effect("heal", data.on_battle_start_heal, data)
		system.push_external_log("%s 触发：战斗开始恢复 %d 生命" % [data.title, data.on_battle_start_heal])


func on_turn_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_turn_start_block > 0:
		system.dispatch_relic_effect("add_block", data.on_turn_start_block, data)
		system.push_external_log("%s 触发：回合开始获得 %d 格挡" % [data.title, data.on_turn_start_block])


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
