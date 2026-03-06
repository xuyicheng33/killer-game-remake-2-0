extends Node

var stats: Stats


func take_damage(amount: int) -> void:
	if stats == null:
		return
	stats.take_damage(amount)
