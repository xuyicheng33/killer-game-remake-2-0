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
	# 触发初始渲染
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
	status_label.text = str(projection.get("status_text", ""))

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
		btn.custom_minimum_size = Vector2(0, 64)
		btn.disabled = bool(button_data.get("disabled", true))
		btn.pressed.connect(_on_buy_offer.bind(index))

		# Connect tooltip hover signals
		var tooltip_icon: Texture = button_data.get("tooltip_icon")
		var tooltip_body: String = str(button_data.get("tooltip_text", ""))
		if tooltip_body.length() > 0:
			btn.mouse_entered.connect(_on_offer_button_mouse_entered.bind(tooltip_icon, tooltip_body))
			btn.mouse_exited.connect(_on_offer_button_mouse_exited)

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
		btn.custom_minimum_size = Vector2(0, 64)
		btn.disabled = bool(button_data.get("disabled", true))
		btn.pressed.connect(_on_remove_card.bind(index))
		deck_container.add_child(btn)


func _on_buy_offer(index: int) -> void:
	_adapter.execute_buy_offer(index)


func _on_offer_button_mouse_entered(icon: Texture, text: String) -> void:
	Events.card_tooltip_requested.emit(icon, text)


func _on_offer_button_mouse_exited() -> void:
	Events.tooltip_hide_requested.emit()


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
	var horizontal_margin := clampf(viewport_size.x * 0.04, 16.0, 120.0)
	var vertical_margin := clampf(viewport_size.y * 0.05, 14.0, 84.0)
	var reserved_overlay_width := clampf(viewport_size.x * 0.23, 280.0, 460.0)

	content_margin.offset_left = horizontal_margin
	content_margin.offset_top = vertical_margin
	content_margin.offset_right = -(horizontal_margin + reserved_overlay_width)
	content_margin.offset_bottom = -vertical_margin

	var content_width := viewport_size.x + content_margin.offset_right - content_margin.offset_left
	if content_width < 760.0:
		content_margin.offset_right = -horizontal_margin
