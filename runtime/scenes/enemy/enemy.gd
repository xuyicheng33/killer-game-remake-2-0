class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://content/art/white_sprite_material.tres")
const HIGH_RES_MIN_TEXTURE_HEIGHT := 128.0
const TARGET_PORTRAIT_HEIGHT := 360.0
const MAX_PORTRAIT_WIDTH := 220.0
const MIN_PORTRAIT_SCALE := 0.06
const MAX_PORTRAIT_SCALE := 6.0

@export var stats: EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI
@onready var intent_ui: IntentUI = $IntentUI

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action
var battle_context: RefCounted : set = set_battle_context
var _default_sprite_scale := Vector2.ONE
var _display_half_width := 0.0
var _death_notified := false


func _ready() -> void:
	_default_sprite_scale = sprite_2d.scale
	if not Events.enemy_action_completed.is_connected(_on_enemy_action_completed):
		Events.enemy_action_completed.connect(_on_enemy_action_completed)


func _exit_tree() -> void:
	if Events.enemy_action_completed.is_connected(_on_enemy_action_completed):
		Events.enemy_action_completed.disconnect(_on_enemy_action_completed)
	if stats != null and stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.disconnect(update_stats)
		if stats.stats_changed.is_connected(update_action):
			stats.stats_changed.disconnect(update_action)


func set_current_action(value: EnemyAction) -> void:
	current_action = value
	if current_action:
		intent_ui.update_intent(current_action.intent)


func set_battle_context(value: RefCounted) -> void:
	battle_context = value
	if enemy_action_picker:
		enemy_action_picker.battle_context = battle_context


func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	_death_notified = false
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
	
	update_enemy()


func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
		
	var new_action_picker := stats.ai.instantiate() as EnemyActionPicker
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self
	enemy_action_picker.battle_context = battle_context


func update_stats() -> void:
	stats_ui.update_stats(stats)


func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action


func update_enemy() -> void:
	if not stats is Stats: 
		return
	if not is_inside_tree(): 
		await ready
	
	sprite_2d.texture = stats.art
	_apply_portrait_scale()
	arrow.position = Vector2.RIGHT * (_display_half_width + ARROW_OFFSET)
	setup_ai()
	update_stats()


func _apply_portrait_scale() -> void:
	if not sprite_2d.texture:
		sprite_2d.scale = _default_sprite_scale
		_display_half_width = (sprite_2d.get_rect().size.x * sprite_2d.scale.x) / 2.0
		return

	var texture_height := float(sprite_2d.texture.get_size().y)
	if texture_height <= HIGH_RES_MIN_TEXTURE_HEIGHT:
		sprite_2d.scale = _default_sprite_scale
		_display_half_width = (sprite_2d.get_rect().size.x * sprite_2d.scale.x) / 2.0
		return

	var visible_size := _get_visible_texture_size(sprite_2d.texture)
	var visible_height := maxf(1.0, visible_size.y)
	var visible_width := maxf(1.0, visible_size.x)
	var scale_by_height := TARGET_PORTRAIT_HEIGHT / visible_height
	var scale_by_width := MAX_PORTRAIT_WIDTH / visible_width
	var uniform_scale := clampf(minf(scale_by_height, scale_by_width), MIN_PORTRAIT_SCALE, MAX_PORTRAIT_SCALE)
	sprite_2d.scale = Vector2.ONE * uniform_scale
	_display_half_width = (visible_width * uniform_scale) / 2.0


func _get_visible_texture_size(texture: Texture2D) -> Vector2:
	var texture_size := texture.get_size()
	var image := texture.get_image()
	if image.is_empty():
		return Vector2(texture_size.x, texture_size.y)

	var used_rect := image.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return Vector2(texture_size.x, texture_size.y)

	return Vector2(float(used_rect.size.x), float(used_rect.size.y))


func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	
	current_action.perform_action()


func _on_enemy_action_completed(enemy: Enemy) -> void:
	if enemy != self:
		return
	if enemy_action_picker and current_action:
		enemy_action_picker.note_action_executed(current_action)


func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	if _death_notified:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(damage))
	tween.tween_interval(0.17)

	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0 and not _death_notified:
				_death_notified = true
				Events.enemy_died.emit(self)
	)


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()
