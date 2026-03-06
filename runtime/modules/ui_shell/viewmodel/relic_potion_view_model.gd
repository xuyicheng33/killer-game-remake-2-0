class_name RelicPotionViewModel
extends RefCounted


func project(run_state: RunState, latest_log: String) -> Dictionary:
	var empty_detail := {
		"relic_title": "遗物 0/0",
		"relic_items": [],
		"potion_title": "药水 0/0",
		"potion_buttons": [],
		"show_empty_potion_hint": true,
		"empty_potion_hint": "（无可用药水）",
		"log_text": latest_log,
		"battle_only_hint": "药水仅可在战斗中使用。",
		"battle_only_hint_visible": false,
	}
	var projection := {
		"compact_projection": {
			"summary_title": "旅途物资",
			"summary_text": "遗物 0/0 · 药水 0/0",
			"summary_meta": latest_log if not latest_log.is_empty() else "当前无额外战斗日志。",
			"toggle_text": "展开详情",
			"show_empty_hint": true,
			"empty_hint": "当前没有遗物或药水。",
		},
		"battle_projection": empty_detail.duplicate(true),
	}
	if run_state == null:
		return projection

	var relic_count := run_state.relics.size()
	var potion_count := run_state.potions.size()
	var summary_text := "遗物 %d/%d · 药水 %d/%d" % [relic_count, run_state.relic_capacity, potion_count, run_state.potion_capacity]
	var summary_meta := latest_log if not latest_log.is_empty() else "战斗外仅显示摘要，点击可查看完整详情。"
	projection["compact_projection"] = {
		"summary_title": "旅途物资",
		"summary_text": summary_text,
		"summary_meta": summary_meta,
		"toggle_text": "展开详情",
		"show_empty_hint": relic_count == 0 and potion_count == 0,
		"empty_hint": "当前没有遗物或药水。",
	}

	var battle_projection := empty_detail.duplicate(true)
	battle_projection["relic_title"] = "遗物 %d/%d" % [relic_count, run_state.relic_capacity]
	battle_projection["potion_title"] = "药水 %d/%d" % [potion_count, run_state.potion_capacity]
	battle_projection["log_text"] = latest_log if not latest_log.is_empty() else "等待新的战斗日志……"
	battle_projection["relic_items"] = _project_relic_items(run_state)
	battle_projection["potion_buttons"] = _project_potion_buttons(run_state)
	battle_projection["show_empty_potion_hint"] = battle_projection["potion_buttons"].is_empty()
	projection["battle_projection"] = battle_projection
	return projection


func _project_relic_items(run_state: RunState) -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for relic in run_state.relics:
		var relic_data := relic as RelicData
		if relic_data == null:
			continue
		items.append({
			"title": relic_data.title,
			"tooltip_title": relic_data.title,
			"tooltip_body": relic_data.description,
			"tooltip_icon": null,
		})
	return items


func _project_potion_buttons(run_state: RunState) -> Array[Dictionary]:
	var buttons: Array[Dictionary] = []
	for i in range(run_state.potions.size()):
		var potion := run_state.potions[i] as PotionData
		buttons.append({
			"index": i,
			"text": _potion_name(potion),
			"tooltip_title": _potion_name(potion),
			"tooltip_body": _potion_desc(potion),
			"tooltip_icon": _potion_icon(potion),
		})
	return buttons


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
