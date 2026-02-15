class_name Stats
extends Resource

const STATUS_CONTAINER_SCRIPT := preload("res://custom_resources/status_container.gd")

signal stats_changed

@export var max_health := 1
@export var art: Texture

var health: int : set = set_health
var block: int : set = set_block
var _status_container: StatusContainer = STATUS_CONTAINER_SCRIPT.new()


func set_health(value : int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()


func set_block(value : int) -> void:
	block = clampi(value, 0, 999)
	stats_changed.emit()


func take_damage(damage : int) -> void:
	if damage <= 0:
		return
	var initial_damage = damage
	damage = clampi(damage - block, 0, damage)
	self.block = clampi(block - initial_damage, 0, block)
	self.health -= damage


func heal(amount : int) -> void:
	self.health += amount


func get_status(status_id: String) -> int:
	return _status_container.get_stack(status_id)


func set_status(status_id: String, stacks: int) -> void:
	if _status_container.set_stack(status_id, stacks):
		stats_changed.emit()


func add_status(status_id: String, delta: int) -> void:
	if delta == 0:
		return
	var before := _status_container.get_stack(status_id)
	var after := _status_container.add_stack(status_id, delta)
	if before != after:
		stats_changed.emit()


func clear_statuses() -> void:
	if _status_container.snapshot().is_empty():
		return
	_status_container.clear_all()
	stats_changed.emit()


func get_status_snapshot() -> Dictionary:
	return _status_container.snapshot()


func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance._status_container = _status_container.duplicate(true)
	instance._status_container.clear_all()
	instance.health = max_health
	instance.block = 0
	return instance
