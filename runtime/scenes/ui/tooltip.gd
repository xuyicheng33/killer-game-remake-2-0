class_name Tooltip
extends PanelContainer

@export var fade_seconds := 0.2

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
	tooltip_text_label.text = text
	tooltip_text_label.reset_size()
	reset_size()
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
