class_name StatsUI
extends HBoxContainer

const BUFF_SYSTEM := preload("res://modules/buff_system/buff_system.gd")

@onready var block: HBoxContainer = $Block
@onready var block_label: Label = %BlockLabel
@onready var health: HBoxContainer = $Health
@onready var health_label: Label = %HealthLabel
@onready var statuses: HBoxContainer = $Statuses


func _ready() -> void:
	BUFF_SYSTEM.get_instance()


func update_stats(stats: Stats) -> void:
	block_label.text = str(stats.block)
	health_label.text = str(stats.health)
	
	block.visible = stats.block > 0
	health.visible = stats.health > 0
	_update_statuses(stats)


func _update_statuses(stats: Stats) -> void:
	for child in statuses.get_children():
		child.queue_free()

	var buff_system := BUFF_SYSTEM.get_instance()
	var badges := buff_system.get_status_badges(stats)
	for badge_variant in badges:
		if not (badge_variant is Dictionary):
			continue

		var badge: Dictionary = badge_variant
		var stacks_variant: Variant = badge.get("stacks", 0)
		if not (stacks_variant is int):
			continue

		var stacks: int = stacks_variant
		if stacks <= 0:
			continue

		var label_variant: Variant = badge.get("label", "?")
		var status_label := Label.new()
		status_label.add_theme_font_size_override("font_size", 18)
		status_label.text = "%s%s" % [str(label_variant), str(stacks)]
		statuses.add_child(status_label)

	statuses.visible = statuses.get_child_count() > 0
