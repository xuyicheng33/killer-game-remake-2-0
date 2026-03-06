class_name ShopScreen
extends Control

signal shop_completed

const SHOP_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/shop_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state

@onready var content_margin: MarginContainer = %MarginContainer
@onready var gold_label: Label = %GoldLabel
@onready var offers_container: VBoxContainer = %OffersContainer
@onready var deck_container: VBoxContainer = %DeckContainer
@onready var status_label: Label = %StatusLabel
@onready var leave_button: Button = %LeaveButton

var _adapter: ShopUIAdapter = SHOP_UI_ADAPTER_SCRIPT.new() as ShopUIAdapter


func _ready() -> void:
	_connect_signals()
	_apply_responsive_layout()
	_apply_action_button_style(leave_button, UIColors.ACCENT)
	_adapter.refresh()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	if not _adapter.shop_completed.is_connected(_on_shop_completed):
		_adapter.shop_completed.connect(_on_shop_completed)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	if not leave_button.pressed.is_connected(_on_leave_pressed):
		leave_button.pressed.connect(_on_leave_pressed)


func _disconnect_signals() -> void:
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)
	if _adapter.shop_completed.is_connected(_on_shop_completed):
		_adapter.shop_completed.disconnect(_on_shop_completed)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if leave_button.pressed.is_connected(_on_leave_pressed):
		leave_button.pressed.disconnect(_on_leave_pressed)


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return
	gold_label.text = str(projection.get("gold_text", "金币：--"))
	status_label.text = str(projection.get("status_text", "完成操作后可继续前进。"))
	_render_offers(projection)
	_render_deck(projection)


func _render_offers(projection: Dictionary) -> void:
	for child in offers_container.get_children():
		child.queue_free()

	var offer_buttons: Variant = projection.get("offer_buttons", [])
	if not (offer_buttons is Array):
		return

	for button_variant in offer_buttons:
		if not (button_variant is Dictionary):
			continue
		var button_data: Dictionary = button_variant
		var index := int(button_data.get("index", -1))
		if index < 0:
			continue
		var btn := Button.new()
		btn.text = str(button_data.get("text", "购买卡牌"))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, UILayout.BTN_HEIGHT_DEFAULT)
		btn.disabled = bool(button_data.get("disabled", true))
		btn.pressed.connect(_on_buy_offer.bind(index))
		var tooltip_icon: Texture = button_data.get("tooltip_icon")
		var tooltip_title := str(button_data.get("tooltip_title", btn.text))
		var tooltip_body := str(button_data.get("tooltip_body", ""))
		var accent := _accent_for_offer(tooltip_title)
		_apply_action_button_style(btn, accent)
		if tooltip_body.length() > 0 or tooltip_title.length() > 0:
			btn.mouse_entered.connect(_emit_tooltip.bind("card", tooltip_title, tooltip_body, tooltip_icon, accent, "shop_offer:%d" % index))
			btn.mouse_exited.connect(_on_tooltip_mouse_exited)
		offers_container.add_child(btn)


func _render_deck(projection: Dictionary) -> void:
	for child in deck_container.get_children():
		child.queue_free()

	var deck_buttons: Variant = projection.get("deck_buttons", [])
	if not (deck_buttons is Array):
		return

	for button_variant in deck_buttons:
		if not (button_variant is Dictionary):
			continue
		var button_data: Dictionary = button_variant
		var index := int(button_data.get("index", -1))
		if index < 0:
			continue
		var btn := Button.new()
		btn.text = str(button_data.get("text", "移除卡牌"))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, UILayout.BTN_HEIGHT_DEFAULT)
		btn.disabled = bool(button_data.get("disabled", true))
		btn.pressed.connect(_on_remove_card.bind(index))
		_apply_action_button_style(btn, UIColors.WARNING)
		deck_container.add_child(btn)


func _accent_for_offer(tooltip_title: String) -> Color:
	if tooltip_title.contains("遗物") or tooltip_title.contains("徽章"):
		return UIColors.TOOLTIP_RELIC
	if tooltip_title.contains("药水"):
		return UIColors.TOOLTIP_POTION
	return UIColors.TOOLTIP_CARD


func _apply_action_button_style(button: Button, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = UIColors.BG_PANEL_SOFT
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = accent.darkened(0.1)
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.content_margin_left = 18
	normal.content_margin_top = 14
	normal.content_margin_right = 18
	normal.content_margin_bottom = 14
	var hover := normal.duplicate()
	hover.bg_color = UIColors.BG_HUD
	hover.border_color = accent.lightened(0.2)
	var pressed := normal.duplicate()
	pressed.bg_color = UIColors.BG_DARK
	pressed.border_color = accent
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)


func _emit_tooltip(kind: String, title: String, body: String, icon: Texture, accent_color: Color, source_id: String) -> void:
	Events.tooltip_requested.emit({
		"kind": kind,
		"title": title,
		"body": body,
		"icon": icon,
		"accent_color": accent_color,
		"source_id": source_id,
	})


func _on_tooltip_mouse_exited() -> void:
	Events.tooltip_hide_requested.emit()


func _on_buy_offer(index: int) -> void:
	_adapter.execute_buy_offer(index)


func _on_remove_card(index: int) -> void:
	_adapter.execute_remove_card(index)


func _on_leave_pressed() -> void:
	_adapter.execute_leave()


func _on_shop_completed() -> void:
	shop_completed.emit()


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return
	var viewport_size := get_viewport_rect().size
	UILayout.apply_screen_frame_layout(content_margin, viewport_size)
