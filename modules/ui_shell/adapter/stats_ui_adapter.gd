class_name StatsUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)

const STATS_VIEW_MODEL_SCRIPT := preload("res://modules/ui_shell/viewmodel/stats_view_model.gd")

var _stats: Stats
var _view_model: StatsViewModel = STATS_VIEW_MODEL_SCRIPT.new() as StatsViewModel


func set_stats(value: Stats) -> void:
	if _stats == value:
		refresh()
		return

	if _stats != null and _stats.stats_changed.is_connected(_on_stats_changed):
		_stats.stats_changed.disconnect(_on_stats_changed)

	_stats = value
	if _stats != null and not _stats.stats_changed.is_connected(_on_stats_changed):
		_stats.stats_changed.connect(_on_stats_changed)
	refresh()


func refresh() -> void:
	projection_changed.emit(_view_model.project(_stats))


func _on_stats_changed() -> void:
	refresh()
