class_name StatsUI
extends HBoxContainer

const STATS_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/stats_ui_adapter.gd")

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health: HBoxContainer = $Health
@onready var health_label: Label = %HealthLabel
@onready var statuses: HBoxContainer = $Statuses

var _adapter: StatsUIAdapter = STATS_UI_ADAPTER_SCRIPT.new() as StatsUIAdapter

func _ready() -> void:
	if not _adapter.projection_changed.is_connected(_apply_projection):
		_adapter.projection_changed.connect(_apply_projection)
	_adapter.refresh()


func update_stats(stats: Stats) -> void:
	_adapter.set_stats(stats)


func _apply_projection(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	block_label.text = str(projection.get("block_text", "0"))
	health_label.text = str(projection.get("health_text", "0"))
	block.visible = bool(projection.get("block_visible", false))
	health.visible = bool(projection.get("health_visible", false))

	for child in statuses.get_children():
		child.queue_free()

	var status_badges_variant: Variant = projection.get("status_badges", [])
	if status_badges_variant is Array:
		for badge_variant in status_badges_variant:
			var status_label := Label.new()
			status_label.add_theme_font_size_override("font_size", 18)
			status_label.text = str(badge_variant)
			statuses.add_child(status_label)

	statuses.visible = bool(projection.get("statuses_visible", false))
