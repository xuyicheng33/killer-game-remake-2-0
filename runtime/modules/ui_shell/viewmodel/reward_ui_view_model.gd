class_name RewardUIViewModel
extends RefCounted


func project(bundle: RewardBundle) -> Dictionary:
	var projection := {
		"gold_text": "金币：+0",
		"extra_reward_text": "额外奖励：无",
		"card_choices": [],
		"has_cards": false,
		"empty_hint": "",
	}

	if bundle == null:
		return projection

	projection["gold_text"] = "金币：+%d" % bundle.gold
	projection["extra_reward_text"] = _format_extra_rewards(bundle)
	projection["card_choices"] = _project_card_choices(bundle)
	projection["has_cards"] = not bundle.card_choices.is_empty()

	if bundle.card_choices.is_empty():
		projection["empty_hint"] = "当前无卡牌奖励，可直接继续前进。"

	return projection


func _format_extra_rewards(bundle: RewardBundle) -> String:
	if bundle == null:
		return "额外奖励：无"

	var parts: PackedStringArray = []
	if bundle.relic_reward != null:
		parts.append("遗物：%s" % bundle.relic_reward.title)
	if bundle.potion_reward != null:
		parts.append("药水：%s" % bundle.potion_reward.title)
	if parts.is_empty():
		return "额外奖励：无"
	return "额外奖励：" + " / ".join(parts)


func _project_card_choices(bundle: RewardBundle) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []

	if bundle == null:
		return choices

	for card in bundle.card_choices:
		choices.append({
			"card": card,
			"text": _format_card_label(card),
			"tooltip": card.tooltip_text if card != null and card.tooltip_text.length() > 0 else "",
		})

	return choices


func _format_card_label(card: Card) -> String:
	if card == null:
		return "(null card)"
	return "%s  [费:%s]" % [card.get_display_name(), card.get_cost_label()]
