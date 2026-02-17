class_name EventUIViewModel
extends RefCounted


func project(template: Dictionary, result_text: String, continue_visible: bool) -> Dictionary:
	return {
		"title": str(template.get("title", "未知事件")),
		"description": str(template.get("description", "没有描述。")),
		"options": _project_options(template),
		"result_text": result_text,
		"continue_visible": continue_visible,
	}


func _project_options(template: Dictionary) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var raw_options := template.get("options", []) as Array

	for option in raw_options:
		var option_dict := option as Dictionary
		options.append({
			"label": str(option_dict.get("label", "选项")),
			"option_data": option_dict,
		})

	return options
