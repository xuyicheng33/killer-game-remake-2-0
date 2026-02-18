class_name StatsViewModel
extends RefCounted


func project(stats: Stats, buff_system: BuffSystem = null) -> Dictionary:
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
	if buff_system == null:
		buff_system = BuffSystem.new()
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
