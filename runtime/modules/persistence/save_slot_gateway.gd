class_name SaveSlotGateway
extends RefCounted


static func has_save(save_path: String) -> bool:
	return FileAccess.file_exists(save_path)


static func write_payload(save_path: String, payload: Dictionary) -> Dictionary:
	var json_text: String = JSON.stringify(payload)
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var open_err: int = FileAccess.get_open_error()
		return {
			"ok": false,
			"code": "io_open_failed",
			"message": "存档写入失败：%s" % error_string(open_err),
		}

	file.store_string(json_text)
	file.close()
	return {
		"ok": true,
		"code": "ok",
		"message": "存档成功。",
	}


static func read_payload(save_path: String) -> Dictionary:
	if not has_save(save_path):
		return {
			"ok": false,
			"code": "missing",
			"message": "未找到本地存档。",
		}

	var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		var open_err: int = FileAccess.get_open_error()
		return {
			"ok": false,
			"code": "io_open_failed",
			"message": "存档读取失败：%s" % error_string(open_err),
		}

	var raw_text: String = file.get_as_text()
	file.close()

	var parser := JSON.new()
	var parse_err: int = parser.parse(raw_text)
	if parse_err != OK:
		return {
			"ok": false,
			"code": "parse_failed",
			"message": "存档解析失败：%s" % parser.get_error_message(),
		}
	if typeof(parser.data) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"code": "format_invalid",
			"message": "存档格式非法：根节点不是对象。",
		}

	return {
		"ok": true,
		"code": "ok",
		"message": "读档成功。",
		"payload": parser.data as Dictionary,
	}


static func clear(save_path: String) -> Dictionary:
	if not has_save(save_path):
		return {
			"ok": true,
			"code": "ok",
			"message": "无存档可清理。",
		}

	var absolute_path: String = ProjectSettings.globalize_path(save_path)
	var err: int = DirAccess.remove_absolute(absolute_path)
	if err != OK:
		return {
			"ok": false,
			"code": "delete_failed",
			"message": "删除存档失败：%s" % error_string(err),
		}

	return {
		"ok": true,
		"code": "ok",
		"message": "存档已删除。",
	}
