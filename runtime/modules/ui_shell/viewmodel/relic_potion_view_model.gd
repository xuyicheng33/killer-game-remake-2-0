class_name RelicPotionViewModel
extends RefCounted


func project(run_state: RunState, latest_log: String) -> Dictionary:
	var projection := {
		"relic_title": "遗物 0/0",
		"relic_items": [],
		"potion_title": "药水 0/0",
		"log_text": latest_log,
		"potion_buttons": [],
		"show_empty_potion_hint": true,
		"empty_potion_hint": "（无可用药水）",
	}
	if run_state == null:
		return projection

	projection["relic_title"] = "遗物 %d/%d" % [run_state.relics.size(), run_state.relic_capacity]
	projection["potion_title"] = "药水 %d/%d" % [run_state.potions.size(), run_state.potion_capacity]

	var relic_items: Array[Dictionary] = []
	for relic in run_state.relics:
		var relic_data := relic as RelicData
		if relic_data == null:
			continue
		relic_items.append({
			"title": relic_data.title,
			"tooltip_text": "[center]%s\n%s[/center]" % [relic_data.title, relic_data.description],
			"tooltip_icon": null,
		})
	projection["relic_items"] = relic_items

	var potion_buttons: Array[Dictionary] = []
	for i in range(run_state.potions.size()):
		var potion := run_state.potions[i] as PotionData
		potion_buttons.append(
			{
				"index": i,
				"text": "使用：%s" % _potion_name(potion),
				"tooltip_text": "[center]%s\n%s[/center]" % [_potion_name(potion), _potion_desc(potion)],
				"tooltip_icon": _potion_icon(potion),
			}
		)

	projection["potion_buttons"] = potion_buttons
	projection["show_empty_potion_hint"] = potion_buttons.is_empty()
	return projection


func _potion_name(potion: PotionData) -> String:
	if potion == null:
		return "(无效药水)"
	return potion.title


func _potion_desc(potion: PotionData) -> String:
	if potion == null:
		return ""
	return potion.description


func _potion_icon(_potion: PotionData) -> Texture:
	return null
