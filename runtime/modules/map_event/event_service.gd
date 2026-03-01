class_name EventService
extends RefCounted

const EVENT_CATALOG_SCRIPT := preload("res://runtime/modules/map_event/event_catalog.gd")
const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")
const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")


static func pick_event_template(run_state: RunState) -> Dictionary:
	var templates := EVENT_CATALOG_SCRIPT.get_templates()
	if templates.is_empty():
		return {}

	var visited_size: int = run_state.map_visited_node_ids.size() if run_state else 0
	var floor_value: int = run_state.floor if run_state else 0
	var seed_value: int = run_state.seed if run_state else 0
	var stream_key: String = "event_template:f%d:v%d" % [floor_value, visited_size]
	var rng: RandomNumberGenerator = RUN_RNG_SCRIPT.create_seeded_rng(seed_value, stream_key)

	var index := rng.randi_range(0, templates.size() - 1)
	var template_variant: Variant = templates[index]
	if template_variant is Dictionary:
		return (template_variant as Dictionary).duplicate(true)
	return {}


static func apply_option(run_state: RunState, option: Dictionary) -> String:
	if run_state == null:
		return "无效状态：未应用事件效果。"

	var effect := str(option.get("effect", "none"))
	match effect:
		"none":
			return "你什么都没做。"
		"gold":
			var value := int(option.get("value", 0))
			run_state.add_gold(value)
			return "金币变化：%+d" % value
		"heal":
			var heal_value := int(option.get("value", 0))
			run_state.heal_player(heal_value)
			return "恢复生命：%d" % maxi(0, heal_value)
		"gold_for_hp":
			var hp_loss := int(option.get("hp", 0))
			var gold_gain := int(option.get("gold", 0))
			run_state.damage_player(hp_loss)
			run_state.add_gold(gold_gain)
			return "失去 %d 生命，获得 %d 金币" % [maxi(0, hp_loss), gold_gain]
		"add_card":
			var added := _add_random_card(run_state)
			return "获得卡牌：%s" % added
		"add_card_for_hp":
			var hp_cost := int(option.get("hp", 0))
			run_state.damage_player(hp_cost)
			var card_name := _add_random_card(run_state)
			return "失去 %d 生命，获得卡牌：%s" % [maxi(0, hp_cost), card_name]
		"buy_card":
			var cost := int(option.get("cost", 0))
			if not run_state.spend_gold(cost):
				return "金币不足，交易失败。"
			var bought := _add_random_card(run_state)
			if bought.begins_with("("):
				run_state.add_gold(cost)
				return "交易失败：%s，已退款 %d 金币" % [bought, maxi(0, cost)]
			return "支付 %d 金币，获得卡牌：%s" % [maxi(0, cost), bought]
		"upgrade_card":
			var upgraded := _upgrade_first_card(run_state)
			return "升级卡牌：%s" % upgraded
		"upgrade_for_hp":
			var hp_pay := int(option.get("hp", 0))
			run_state.damage_player(hp_pay)
			var upgraded_name := _upgrade_first_card(run_state)
			return "失去 %d 生命，升级卡牌：%s" % [maxi(0, hp_pay), upgraded_name]
		"remove_card":
			var removed := _remove_first_card(run_state)
			return "移除卡牌：%s" % removed
		"heal_for_gold":
			var pay_gold := int(option.get("gold", 0))
			var heal_amount := int(option.get("heal", 0))
			if not run_state.spend_gold(pay_gold):
				return "金币不足，未能完成交易。"
			run_state.heal_player(heal_amount)
			return "支付 %d 金币，恢复 %d 生命" % [maxi(0, pay_gold), maxi(0, heal_amount)]
		"max_hp":
			var hp_gain := int(option.get("value", 0))
			run_state.increase_max_health(hp_gain)
			return "最大生命 +%d" % maxi(0, hp_gain)
		"cards_for_hp":
			var hp_cost2 := int(option.get("hp", 0))
			var count := maxi(1, int(option.get("count", 1)))
			run_state.damage_player(hp_cost2)
			var names: PackedStringArray = []
			for _i in range(count):
				names.append(_add_random_card(run_state))
			return "失去 %d 生命，获得卡牌：%s" % [maxi(0, hp_cost2), ", ".join(names)]
		_:
			return "未知效果：%s" % effect


static func _add_random_card(run_state: RunState) -> String:
	var pool := REWARD_GENERATOR_SCRIPT.get_card_pool_for_run(run_state)
	if pool.is_empty():
		return "(无可用卡池)"
	var floor_value: int = run_state.floor if run_state else 0
	var visited_size: int = run_state.map_visited_node_ids.size() if run_state else 0
	var stream_key: String = "event_card:f%d:v%d" % [floor_value, visited_size]
	var card: Card = REWARD_GENERATOR_SCRIPT.pick_random_card(pool, stream_key)
	if card == null:
		return "(无效卡)"
	if not run_state.add_card_to_deck(card):
		return "(加牌失败)"
	return _card_display_name(card)


static func _upgrade_first_card(run_state: RunState) -> String:
	var cards := run_state.get_deck_cards()
	if cards.is_empty():
		return "(牌组为空)"
	var success := run_state.upgrade_card_in_deck_at(0)
	if not success:
		return "(升级失败)"
	var first_card_variant: Variant = cards[0]
	if first_card_variant is Card:
		return _card_display_name(first_card_variant as Card)
	return "(升级完成)"


static func _remove_first_card(run_state: RunState) -> String:
	var cards := run_state.get_deck_cards()
	if cards.size() <= 1:
		return "(牌组无法继续移除)"
	var removed := run_state.remove_card_from_deck_at(0)
	if removed == null:
		return "(移除失败)"
	return _card_display_name(removed)


static func _card_display_name(card: Card) -> String:
	if card == null:
		return "(无效卡)"
	var display_name := card.get_display_name().strip_edges()
	if not display_name.is_empty():
		return display_name
	var card_id := card.id.strip_edges()
	if not card_id.is_empty():
		return card_id
	return "(无效卡)"
