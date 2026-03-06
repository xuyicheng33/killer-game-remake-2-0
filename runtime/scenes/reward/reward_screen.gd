class_name RewardScreen
extends Control

signal reward_completed(bundle: RewardBundle, chosen_card: Card)

const REWARD_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/reward_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state
@export var reward_gold: int = 0 : set = _set_reward_gold

@onready var frame: PanelContainer = %Frame
@onready var gold_label: Label = %GoldLabel
@onready var extra_reward_label: Label = %ExtraRewardLabel
@onready var cards_container: VBoxContainer = %CardsContainer
@onready var skip_button: Button = %SkipButton

var _adapter: RewardUIAdapter = REWARD_UI_ADAPTER_SCRIPT.new() as RewardUIAdapter


func _ready() -> void:
	_connect_signals()
	_apply_responsive_layout()
	_adapter.generate_bundle()
	_apply_static_button_style(skip_button, UIColors.SUCCESS)


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	if not _adapter.reward_completed.is_connected(_on_adapter_reward_completed):
		_adapter.reward_completed.connect(_on_adapter_reward_completed)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	if not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)


func _disconnect_signals() -> void:
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)
	if _adapter.reward_completed.is_connected(_on_adapter_reward_completed):
		_adapter.reward_completed.disconnect(_on_adapter_reward_completed)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)

	if skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.disconnect(_on_skip_pressed)


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _set_reward_gold(value: int) -> void:
	reward_gold = value
	_adapter.set_reward_gold(value)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	gold_label.text = str(projection.get("gold_text", "金币：+0"))
	extra_reward_label.text = str(projection.get("extra_reward_text", "额外奖励：无"))
	_render_cards(projection)


func _render_cards(projection: Dictionary) -> void:
	for child in cards_container.get_children():
		child.queue_free()

	if not bool(projection.get("has_cards", false)):
		var hint := Label.new()
		hint.text = str(projection.get("empty_hint", "当前无卡牌奖励，可直接继续前进。"))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_BODY)
		hint.modulate = UIColors.TEXT_MUTED
		cards_container.add_child(hint)
		return

	var card_choices: Variant = projection.get("card_choices", [])
	if not (card_choices is Array):
		return

	for card_variant in card_choices:
		if not (card_variant is Dictionary):
			continue
		var card_data: Dictionary = card_variant
		var card: Variant = card_data.get("card")
		var btn := Button.new()
		btn.text = str(card_data.get("text", "(null card)"))
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, UILayout.BTN_HEIGHT_CARD)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_BUTTON_LARGE)
		_apply_static_button_style(btn, UIColors.TOOLTIP_CARD)
		var tooltip_title := str(card_data.get("tooltip_title", btn.text))
		var tooltip_body := str(card_data.get("tooltip_body", ""))
		var card_icon: Texture = null
		if card is Card and card.icon != null:
			card_icon = card.icon
		if tooltip_body.length() > 0 or tooltip_title.length() > 0:
			btn.mouse_entered.connect(_emit_tooltip.bind("card", tooltip_title, tooltip_body, card_icon, UIColors.TOOLTIP_CARD, "reward:%s" % tooltip_title))
			btn.mouse_exited.connect(_on_tooltip_mouse_exited)
		btn.pressed.connect(_on_card_pressed.bind(card))
		cards_container.add_child(btn)


func _apply_static_button_style(button: Button, accent: Color) -> void:
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


func _on_card_pressed(card: Card) -> void:
	_adapter.select_card(card)


func _on_skip_pressed() -> void:
	_adapter.skip()


func _on_adapter_reward_completed(bundle: RewardBundle, chosen_card: Card) -> void:
	reward_completed.emit(bundle, chosen_card)


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return
	var viewport_size := get_viewport_rect().size
	UILayout.apply_screen_frame_layout(frame, viewport_size)
