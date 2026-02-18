class_name Player
extends Node2D

const WHITE_SPRITE_MATERIAL := preload("res://content/art/white_sprite_material.tres")
const HIGH_RES_MIN_TEXTURE_HEIGHT := 128.0
const TARGET_PORTRAIT_HEIGHT := 420.0
const MAX_PORTRAIT_WIDTH := 320.0
const MIN_PORTRAIT_SCALE := 0.06
const MAX_PORTRAIT_SCALE := 6.0

@export var stats: CharacterStats : set = set_character_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stats_ui: StatsUI = $StatsUI

var _default_sprite_scale := Vector2.ONE


func _ready() -> void:
	_default_sprite_scale = sprite_2d.scale


func _exit_tree() -> void:
	if stats != null and stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.disconnect(update_stats)


func set_character_stats(value: CharacterStats) -> void:
	if stats != null and stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.disconnect(update_stats)
	stats = value
	
	if stats != null and not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)

	update_player()


func update_player() -> void:
	if not stats is CharacterStats: 
		return
	if not is_inside_tree(): 
		await ready

	sprite_2d.texture = stats.art
	_apply_portrait_scale()
	update_stats()


func update_stats() -> void:
	stats_ui.update_stats(stats)


func _apply_portrait_scale() -> void:
	if not sprite_2d.texture:
		sprite_2d.scale = _default_sprite_scale
		return

	var texture_height := float(sprite_2d.texture.get_size().y)
	if texture_height <= HIGH_RES_MIN_TEXTURE_HEIGHT:
		sprite_2d.scale = _default_sprite_scale
		return

	var visible_size := _get_visible_texture_size(sprite_2d.texture)
	var visible_height := maxf(1.0, visible_size.y)
	var visible_width := maxf(1.0, visible_size.x)
	var scale_by_height := TARGET_PORTRAIT_HEIGHT / visible_height
	var scale_by_width := MAX_PORTRAIT_WIDTH / visible_width
	var uniform_scale := clampf(minf(scale_by_height, scale_by_width), MIN_PORTRAIT_SCALE, MAX_PORTRAIT_SCALE)
	sprite_2d.scale = Vector2.ONE * uniform_scale


func _get_visible_texture_size(texture: Texture2D) -> Vector2:
	var texture_size := texture.get_size()
	var image := texture.get_image()
	if image.is_empty():
		return Vector2(texture_size.x, texture_size.y)

	var used_rect := image.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return Vector2(texture_size.x, texture_size.y)

	return Vector2(float(used_rect.size.x), float(used_rect.size.y))


func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(damage))
	tween.tween_interval(0.17)
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.player_died.emit()
				queue_free()
	)
