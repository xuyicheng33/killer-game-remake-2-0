extends "res://runtime/modules/relic_potion/relic_base.gd"

const LOG_TEMPLATES := preload("res://runtime/global/log_templates.gd")
const CONDITION_CHECKER := preload("res://runtime/modules/relic_potion/relic_condition_checker.gd")


func _init(relic_data: RelicData = null) -> void:
	super(relic_data)


func on_battle_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_battle_start_heal > 0:
		system.dispatch_relic_effect("heal", data.on_battle_start_heal, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_battle_start_heal", data.on_battle_start_heal))


func on_battle_end(system: Object, context: Dictionary) -> void:
	if data == null:
		return
	if data.on_battle_end_heal_per_kill > 0:
		var kills: int = int(context.get("kills", 0))
		if kills > 0:
			var heal_amount := kills * data.on_battle_end_heal_per_kill
			system.dispatch_relic_effect("heal", heal_amount, data)
			system.push_external_log(LOG_TEMPLATES.relic_dual(data.title, "relic_battle_end_heal", kills, heal_amount))


func on_turn_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_turn_start_block > 0:
		system.dispatch_relic_effect("add_block", data.on_turn_start_block, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_turn_start_block", data.on_turn_start_block))
	if data.on_turn_start_energy > 0:
		system.dispatch_relic_effect("add_energy", data.on_turn_start_energy, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_turn_start_energy", data.on_turn_start_energy))
	if data.on_turn_start_damage > 0:
		system.dispatch_relic_effect("take_damage", data.on_turn_start_damage, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_turn_start_damage", data.on_turn_start_damage))


func on_turn_end(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_turn_end_heal > 0:
		system.dispatch_relic_effect("heal", data.on_turn_end_heal, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_turn_end_heal", data.on_turn_end_heal))


func on_card_played(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_card_played_gold <= 0:
		return

	if not CONDITION_CHECKER.check_interval(system.get_cards_played_in_battle(), data.card_play_interval):
		return

	system.dispatch_relic_effect("add_gold", data.on_card_played_gold, data)
	system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_card_played_gold", data.on_card_played_gold))


func on_damage_taken(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_player_hit_block > 0:
		system.dispatch_relic_effect("add_block", data.on_player_hit_block, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_damage_taken_block", data.on_player_hit_block))


func on_block_applied(system: Object, context: Dictionary) -> void:
	if data == null:
		return
	var block_amount := int(context.get("amount", 0))
	if block_amount <= 0:
		return
	system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_block_applied", block_amount))


func on_enemy_killed(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_enemy_killed_gold > 0:
		system.dispatch_relic_effect("add_gold", data.on_enemy_killed_gold, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_enemy_killed_gold", data.on_enemy_killed_gold))
	if data.on_enemy_killed_strength > 0:
		system.dispatch_relic_effect("add_strength", data.on_enemy_killed_strength, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_enemy_killed_strength", data.on_enemy_killed_strength))
	if data.on_enemy_killed_damage > 0:
		system.dispatch_relic_effect("take_damage", data.on_enemy_killed_damage, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_enemy_killed_damage", data.on_enemy_killed_damage))
	if data.on_enemy_killed_draw > 0:
		system.dispatch_relic_effect("draw_cards", data.on_enemy_killed_draw, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_enemy_killed_draw", data.on_enemy_killed_draw))


func on_boss_killed(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_enemy_killed_gold > 0:
		system.dispatch_relic_effect("add_gold", data.on_enemy_killed_gold, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_boss_killed_gold", data.on_enemy_killed_gold))


func on_shop_enter(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.shop_discount_percent > 0:
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_shop_discount", data.shop_discount_percent))


func on_run_start(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_run_start_gold > 0:
		system.dispatch_relic_effect("add_gold", data.on_run_start_gold, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_run_start_gold", data.on_run_start_gold))
	if data.on_run_start_max_health > 0:
		system.dispatch_relic_effect("increase_max_health", data.on_run_start_max_health, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_run_start_max_health", data.on_run_start_max_health))
	if data.on_run_start_strength > 0:
		system.dispatch_relic_effect("add_strength", data.on_run_start_strength, data)
		system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_run_start_strength", data.on_run_start_strength))


func on_attack_played(system: Object, _context: Dictionary) -> void:
	if data == null:
		return
	if data.on_attack_played_strength <= 0:
		return

	var max_triggers: int = maxi(0, data.attack_play_strength_max)
	if not CONDITION_CHECKER.check_and_consume_trigger(system, data.id, "attack_played", max_triggers):
		return

	system.dispatch_relic_effect("add_strength", data.on_attack_played_strength, data)
	system.push_external_log(LOG_TEMPLATES.relic(data.title, "relic_attack_played_strength", data.on_attack_played_strength))
