class_name RelicPotionUI
extends PanelContainer

const RELIC_POTION_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/relic_potion_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state

@onready var relic_label: Label = %RelicLabel
@onready var relic_list_label: VBoxContainer = %RelicListLabel
@onready var potion_label: Label = %PotionLabel
@onready var potion_container: VBoxContainer = %PotionContainer
@onready var log_label: Label = %LogLabel

var relic_potion_system: RelicPotionSystem : set = _set_relic_potion_system
var _adapter: RelicPotionUIAdapter = RELIC_POTION_UI_ADAPTER_SCRIPT.new() as RelicPotionUIAdapter


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _set_relic_potion_system(value: RelicPotionSystem) -> void:
	relic_potion_system = value
	_adapter.set_relic_potion_system(value)


func _ready() -> void:
	_connect_signals()
	_adapter.refresh()
	_apply_responsive_layout()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)


func _disconnect_signals() -> void:
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)


func _on_use_potion(index: int) -> void:
	_adapter.use_potion(index)


func _on_potion_button_mouse_entered(icon: Texture, text: String) -> void:
	Events.potion_tooltip_requested.emit(icon, text)


func _on_potion_button_mouse_exited() -> void:
	Events.tooltip_hide_requested.emit()


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	relic_label.text = str(projection.get("relic_title", "遗物 0/0"))
	_render_relics(projection)
	potion_label.text = str(projection.get("potion_title", "药水 0/0"))
	log_label.text = str(projection.get("log_text", ""))
	_render_potions(projection)


func _render_relics(projection: Dictionary) -> void:
	for child in relic_list_label.get_children():
		child.queue_free()

	var relic_items: Variant = projection.get("relic_items", [])
	if not (relic_items is Array) or relic_items.is_empty():
		var hint := Label.new()
		hint.text = "（无）"
		hint.add_theme_font_size_override("font_size", 18)
		relic_list_label.add_child(hint)
		return

	for item_variant in relic_items:
		if not (item_variant is Dictionary):
			continue
		var item_data: Dictionary = item_variant

		var btn := Button.new()
		btn.text = str(item_data.get("title", "遗物"))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var tooltip_body: String = _resolve_tooltip_text(
			str(item_data.get("tooltip_text", "")),
			btn.text
		)
		btn.tooltip_text = tooltip_body
		var tooltip_icon: Texture = item_data.get("tooltip_icon")
		if tooltip_body.length() > 0:
			btn.mouse_entered.connect(_on_relic_button_mouse_entered.bind(tooltip_icon, tooltip_body))
			btn.mouse_exited.connect(_on_relic_button_mouse_exited)

		relic_list_label.add_child(btn)


func _on_relic_button_mouse_entered(icon: Texture, text: String) -> void:
	Events.relic_tooltip_requested.emit(icon, text)


func _on_relic_button_mouse_exited() -> void:
	Events.tooltip_hide_requested.emit()


func _render_potions(projection: Dictionary) -> void:
	for child in potion_container.get_children():
		child.queue_free()

	var potion_buttons_variant: Variant = projection.get("potion_buttons", [])
	if potion_buttons_variant is Array:
		for button_variant in potion_buttons_variant:
			if not (button_variant is Dictionary):
				continue

			var button_data: Dictionary = button_variant
			var index := int(button_data.get("index", -1))
			if index < 0:
				continue

			var btn := Button.new()
			btn.text = str(button_data.get("text", "使用："))
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.disabled = not bool(button_data.get("enabled", true))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn.pressed.connect(_on_use_potion.bind(index))

			# Connect tooltip hover signals
			var tooltip_icon: Texture = button_data.get("tooltip_icon")
			var tooltip_body: String = _resolve_tooltip_text(
				str(button_data.get("tooltip_text", "")),
				btn.text
			)
			btn.tooltip_text = tooltip_body
			if tooltip_body.length() > 0:
				btn.mouse_entered.connect(_on_potion_button_mouse_entered.bind(tooltip_icon, tooltip_body))
				btn.mouse_exited.connect(_on_potion_button_mouse_exited)

			potion_container.add_child(btn)

	if bool(projection.get("show_empty_potion_hint", false)):
		var hint := Label.new()
		hint.text = str(projection.get("empty_potion_hint", "（无可用药水）"))
		potion_container.add_child(hint)

	if bool(projection.get("battle_only_hint_visible", false)):
		var battle_hint := Label.new()
		battle_hint.text = str(projection.get("battle_only_hint", "药水仅可在战斗中使用。"))
		battle_hint.add_theme_font_size_override("font_size", 14)
		battle_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		potion_container.add_child(battle_hint)


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	var panel_width := clampf(viewport_size.x * 0.23, 300.0, 430.0)
	var panel_height := clampf(viewport_size.y * 0.44, 260.0, 520.0)
	var right_margin := 16.0
	var top_margin := 16.0

	offset_left = -(panel_width + right_margin)
	offset_top = top_margin
	offset_right = -right_margin
	offset_bottom = top_margin + panel_height


func _resolve_tooltip_text(raw: String, fallback: String) -> String:
	var trimmed := raw.strip_edges()
	if trimmed.length() > 0:
		return trimmed
	return fallback.strip_edges()
