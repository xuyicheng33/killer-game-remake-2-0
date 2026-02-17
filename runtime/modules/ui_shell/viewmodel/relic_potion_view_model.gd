class_name RelicPotionViewModel
extends RefCounted


func project(run_state: RunState, latest_log: String) -> Dictionary:
	var projection := {
		"relic_title": "遗物 0/0",
		"relic_list_text": "（无）",
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

	var relic_names: PackedStringArray = []
	for relic in run_state.relics:
		var relic_data := relic as RelicData
		if relic_data == null:
			continue
		relic_names.append(relic_data.title)
	projection["relic_list_text"] = ", ".join(relic_names) if not relic_names.is_empty() else "（无）"

	var potion_buttons: Array[Dictionary] = []
	for i in range(run_state.potions.size()):
		var potion := run_state.potions[i] as PotionData
		potion_buttons.append(
			{
				"index": i,
				"text": "使用：%s" % _potion_name(potion),
			}
		)

	projection["potion_buttons"] = potion_buttons
	projection["show_empty_potion_hint"] = potion_buttons.is_empty()
	return projection


func _potion_name(potion: PotionData) -> String:
	if potion == null:
		return "(无效药水)"
	return potion.title
