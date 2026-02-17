class_name StatsViewModel
extends RefCounted

const BUFF_SYSTEM_SCRIPT := preload("res://runtime/modules/buff_system/buff_system.gd")


func project(stats: Stats) -> Dictionary:
	var projection := {
		"block_text": "0",
		"health_text": "0",
		"block_visible": false,
		"health_visible": false,
		"statuses_visible": false,
		"status_badges": [],
	}
	if stats == null:
		return projection

	var status_badges: Array[String] = []
	var buff_system := BUFF_SYSTEM_SCRIPT.get_instance()
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
		status_badges.append("%s%s" % [str(label_variant), str(stacks)])

	projection["block_text"] = str(stats.block)
	projection["health_text"] = str(stats.health)
	projection["block_visible"] = stats.block > 0
	projection["health_visible"] = stats.health > 0
	projection["statuses_visible"] = not status_badges.is_empty()
	projection["status_badges"] = status_badges
	return projection
