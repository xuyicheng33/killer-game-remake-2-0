class_name Tooltip
extends PanelContainer

@export var fade_seconds := 0.2

const MAX_TOOLTIP_WIDTH := 420.0
const TOOLTIP_EDGE_MARGIN := 16.0
const TOOLTIP_CURSOR_OFFSET := Vector2(18.0, 18.0)

@onready var tooltip_icon: TextureRect = %TooltipIcon
@onready var tooltip_text_label: RichTextLabel = %TooltipText

var tween: Tween
var is_visible_now := false


func _ready() -> void:
	_connect_signals()
	modulate = Color.TRANSPARENT
	hide()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not Events.card_tooltip_requested.is_connected(show_tooltip):
		Events.card_tooltip_requested.connect(show_tooltip)
	if not Events.relic_tooltip_requested.is_connected(show_tooltip):
		Events.relic_tooltip_requested.connect(show_tooltip)
	if not Events.potion_tooltip_requested.is_connected(show_tooltip):
		Events.potion_tooltip_requested.connect(show_tooltip)
	if not Events.tooltip_hide_requested.is_connected(hide_tooltip):
		Events.tooltip_hide_requested.connect(hide_tooltip)


func _disconnect_signals() -> void:
	if Events.card_tooltip_requested.is_connected(show_tooltip):
		Events.card_tooltip_requested.disconnect(show_tooltip)
	if Events.relic_tooltip_requested.is_connected(show_tooltip):
		Events.relic_tooltip_requested.disconnect(show_tooltip)
	if Events.potion_tooltip_requested.is_connected(show_tooltip):
		Events.potion_tooltip_requested.disconnect(show_tooltip)
	if Events.tooltip_hide_requested.is_connected(hide_tooltip):
		Events.tooltip_hide_requested.disconnect(hide_tooltip)


func show_tooltip(icon: Texture, text: String) -> void:
	is_visible_now = true
	if tween:
		tween.kill()
	
	tooltip_icon.texture = icon
	tooltip_icon.visible = icon != null
	tooltip_icon.custom_minimum_size = Vector2(0, 64) if icon != null else Vector2.ZERO
	tooltip_text_label.text = text
	tooltip_text_label.custom_minimum_size.x = MAX_TOOLTIP_WIDTH - 32.0
	reset_size()
	call_deferred("_position_near_cursor")
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(show)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)


func hide_tooltip() -> void:
	is_visible_now = false
	if tween:
		tween.kill()

	get_tree().create_timer(fade_seconds, false).timeout.connect(hide_animation)


func hide_animation() -> void:
	if not is_visible_now:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_seconds)
		tween.tween_callback(hide)


func _position_near_cursor() -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return

	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var tooltip_size: Vector2 = size
	if tooltip_size.x <= 0.0 or tooltip_size.y <= 0.0:
		tooltip_size = get_combined_minimum_size()

	var mouse_pos: Vector2 = viewport.get_mouse_position()
	var next_pos := mouse_pos + TOOLTIP_CURSOR_OFFSET

	if next_pos.x + tooltip_size.x > viewport_size.x - TOOLTIP_EDGE_MARGIN:
		next_pos.x = mouse_pos.x - tooltip_size.x - TOOLTIP_CURSOR_OFFSET.x
	if next_pos.y + tooltip_size.y > viewport_size.y - TOOLTIP_EDGE_MARGIN:
		next_pos.y = viewport_size.y - tooltip_size.y - TOOLTIP_EDGE_MARGIN

	next_pos.x = clampf(next_pos.x, TOOLTIP_EDGE_MARGIN, viewport_size.x - tooltip_size.x - TOOLTIP_EDGE_MARGIN)
	next_pos.y = clampf(next_pos.y, TOOLTIP_EDGE_MARGIN, viewport_size.y - tooltip_size.y - TOOLTIP_EDGE_MARGIN)
	position = next_pos
