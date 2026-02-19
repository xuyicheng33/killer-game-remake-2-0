class_name EnemyAction
extends Node

enum Type {CONDITIONAL, CHANCE_BASED}

@export var intent: Intent
@export var sound: AudioStream
@export var type: Type
@export_range(0.0, 10.0) var chance_weight := 0.0

@onready var accumulated_weight := 0.0

var enemy: Enemy
var target: Node2D
var battle_context: RefCounted


func is_performable() -> bool:
	return false


func get_effective_weight(_ascension_level: int) -> float:
	# Ascension placeholder: future actions can override for scaling.
	# Base behavior: use the configured weight.
	return chance_weight


func perform_action() -> void:
	pass
