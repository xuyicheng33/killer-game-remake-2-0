class_name Tooltip
extends PanelContainer

@export var fade_seconds := 0.18
@export var hover_delay_seconds := 0.14

const MAX_TOOLTIP_WIDTH := 460.0
const TOOLTIP_EDGE_MARGIN := 18.0
const TOOLTIP_CURSOR_OFFSET := Vector2(18.0, 18.0)

@onready var accent_bar: ColorRect = %AccentBar
@onready var kind_label: Label = %TooltipKind
@onready var title_label: Label = %TooltipTitle
@onready var tooltip_icon: TextureRect = %TooltipIcon
@onready var tooltip_body: RichTextLabel = %TooltipBody

var tween: Tween
var _is_requested := false
var _request_version := 0
var _active_source_id := ""


func _ready() -> void:
	_connect_signals()
	modulate = Color(1, 1, 1, 0)
	hide()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not TooltipEvents.tooltip_requested.is_connected(_on_tooltip_requested):
		TooltipEvents.tooltip_requested.connect(_on_tooltip_requested)
	if not TooltipEvents.card_tooltip_requested.is_connected(_on_legacy_card_tooltip):
		TooltipEvents.card_tooltip_requested.connect(_on_legacy_card_tooltip)
	if not TooltipEvents.relic_tooltip_requested.is_connected(_on_legacy_relic_tooltip):
		TooltipEvents.relic_tooltip_requested.connect(_on_legacy_relic_tooltip)
	if not TooltipEvents.potion_tooltip_requested.is_connected(_on_legacy_potion_tooltip):
		TooltipEvents.potion_tooltip_requested.connect(_on_legacy_potion_tooltip)
	if not TooltipEvents.tooltip_hide_requested.is_connected(hide_tooltip):
		TooltipEvents.tooltip_hide_requested.connect(hide_tooltip)


func _disconnect_signals() -> void:
	if TooltipEvents.tooltip_requested.is_connected(_on_tooltip_requested):
		TooltipEvents.tooltip_requested.disconnect(_on_tooltip_requested)
	if TooltipEvents.card_tooltip_requested.is_connected(_on_legacy_card_tooltip):
		TooltipEvents.card_tooltip_requested.disconnect(_on_legacy_card_tooltip)
	if TooltipEvents.relic_tooltip_requested.is_connected(_on_legacy_relic_tooltip):
		TooltipEvents.relic_tooltip_requested.disconnect(_on_legacy_relic_tooltip)
	if TooltipEvents.potion_tooltip_requested.is_connected(_on_legacy_potion_tooltip):
		TooltipEvents.potion_tooltip_requested.disconnect(_on_legacy_potion_tooltip)
	if TooltipEvents.tooltip_hide_requested.is_connected(hide_tooltip):
		TooltipEvents.tooltip_hide_requested.disconnect(hide_tooltip)


func _on_tooltip_requested(payload: Dictionary) -> void:
	_is_requested = true
	_request_version += 1
	var version := _request_version
	var wait_seconds := hover_delay_seconds
	if visible and _active_source_id == str(payload.get("source_id", "")):
		wait_seconds = 0.0
	if wait_seconds <= 0.0:
		_show_payload(payload)
		return
	get_tree().create_timer(wait_seconds, false).timeout.connect(
		func() -> void:
			if version != _request_version or not _is_requested:
				return
			_show_payload(payload)
	)


func _on_legacy_card_tooltip(icon: Texture, text: String) -> void:
	_on_tooltip_requested(_legacy_payload("card", icon, text, UIColors.TOOLTIP_CARD))


func _on_legacy_relic_tooltip(icon: Texture, text: String) -> void:
	_on_tooltip_requested(_legacy_payload("relic", icon, text, UIColors.TOOLTIP_RELIC))


func _on_legacy_potion_tooltip(icon: Texture, text: String) -> void:
	_on_tooltip_requested(_legacy_payload("potion", icon, text, UIColors.TOOLTIP_POTION))


func _show_payload(payload: Dictionary) -> void:
	_active_source_id = str(payload.get("source_id", ""))
	_apply_payload(payload)
	_position_near_cursor()
	if tween:
		tween.kill()
	show()
	modulate = Color(1, 1, 1, 0)
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color.WHITE, fade_seconds)


func hide_tooltip() -> void:
	_is_requested = false
	_request_version += 1
	_active_source_id = ""
	if tween:
		tween.kill()
	if not visible:
		return
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), fade_seconds)
	tween.tween_callback(hide)


func _apply_payload(payload: Dictionary) -> void:
	var title := str(payload.get("title", "详情"))
	var body := str(payload.get("body", ""))
	var kind := str(payload.get("kind", ""))
	var icon: Texture = payload.get("icon")
	var accent: Variant = payload.get("accent_color", UIColors.TOOLTIP_DEFAULT)
	if body.is_empty():
		body = title
	if title.is_empty():
		title = "详情"
	title_label.text = title
	tooltip_body.text = body
	tooltip_body.custom_minimum_size.x = MAX_TOOLTIP_WIDTH - 32.0
	kind_label.text = _kind_text(kind)
	kind_label.visible = not kind_label.text.is_empty()
	tooltip_icon.texture = icon
	tooltip_icon.visible = icon != null
	tooltip_icon.custom_minimum_size = Vector2(56, 56) if icon != null else Vector2.ZERO
	accent_bar.color = accent if accent is Color else UIColors.TOOLTIP_DEFAULT
	reset_size()


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


func _legacy_payload(kind: String, icon: Texture, text: String, accent_color: Color) -> Dictionary:
	var stripped := text.replace("[center]", "").replace("[/center]", "")
	var title := ""
	var body := stripped
	if stripped.contains("\n\n"):
		var split_parts := stripped.split("\n\n", false, 1)
		title = split_parts[0]
		body = split_parts[1] if split_parts.size() > 1 else ""
	elif stripped.contains("\n"):
		var lines := stripped.split("\n", false, 1)
		title = lines[0]
		body = lines[1] if lines.size() > 1 else ""
	return {
		"kind": kind,
		"title": title,
		"body": body,
		"icon": icon,
		"accent_color": accent_color,
		"source_id": kind,
	}


func _kind_text(kind: String) -> String:
	match kind:
		"card":
			return "卡牌说明"
		"relic":
			return "遗物说明"
		"potion":
			return "药水说明"
		_:
			return ""
