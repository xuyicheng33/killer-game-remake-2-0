class_name RelicPotionUI
extends PanelContainer

const RELIC_POTION_UI_ADAPTER_SCRIPT := preload("res://runtime/modules/ui_shell/adapter/relic_potion_ui_adapter.gd")

enum OverlayMode {
	HIDDEN,
	COMPACT,
	BATTLE,
}

@export var run_state: RunState : set = _set_run_state

@onready var summary_title_label: Label = %SummaryTitleLabel
@onready var summary_text_label: Label = %SummaryTextLabel
@onready var summary_meta_label: Label = %SummaryMetaLabel
@onready var toggle_button: Button = %ToggleButton
@onready var detail_root: VBoxContainer = %DetailRoot
@onready var relic_label: Label = %RelicLabel
@onready var relic_list_label: VBoxContainer = %RelicListLabel
@onready var potion_label: Label = %PotionLabel
@onready var potion_container: VBoxContainer = %PotionContainer
@onready var log_label: Label = %LogLabel
@onready var empty_hint_label: Label = %EmptyHintLabel

var relic_potion_system: RelicPotionSystem : set = _set_relic_potion_system
var _adapter: RelicPotionUIAdapter = RELIC_POTION_UI_ADAPTER_SCRIPT.new() as RelicPotionUIAdapter
var _overlay_mode: OverlayMode = OverlayMode.HIDDEN
var _compact_expanded := false
var _latest_projection: Dictionary = {}


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _set_relic_potion_system(value: RelicPotionSystem) -> void:
	relic_potion_system = value
	_adapter.set_relic_potion_system(value)


func _ready() -> void:
	_connect_signals()
	_adapter.refresh()
	_apply_overlay_visual_state()
	_apply_responsive_layout()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	if not toggle_button.pressed.is_connected(_on_toggle_pressed):
		toggle_button.pressed.connect(_on_toggle_pressed)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)


func _disconnect_signals() -> void:
	if _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.disconnect(_render)
	if toggle_button.pressed.is_connected(_on_toggle_pressed):
		toggle_button.pressed.disconnect(_on_toggle_pressed)

	var viewport := get_viewport()
	if viewport != null and viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.disconnect(_on_viewport_resized)


func set_overlay_mode(value: int) -> void:
	_overlay_mode = value
	match _overlay_mode:
		OverlayMode.HIDDEN:
			_compact_expanded = false
		OverlayMode.COMPACT:
			_compact_expanded = false
		OverlayMode.BATTLE:
			_compact_expanded = true
	_apply_overlay_visual_state()
	_apply_responsive_layout()


func get_overlay_mode() -> int:
	return int(_overlay_mode)


func _on_toggle_pressed() -> void:
	if _overlay_mode != OverlayMode.COMPACT:
		return
	_compact_expanded = not _compact_expanded
	_apply_overlay_visual_state()
	_apply_responsive_layout()


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return
	_latest_projection = projection.duplicate(true)
	_apply_overlay_visual_state()


func _apply_overlay_visual_state() -> void:
	visible = _overlay_mode != OverlayMode.HIDDEN
	if not visible:
		return

	var compact_variant: Variant = _latest_projection.get("compact_projection", {})
	var battle_variant: Variant = _latest_projection.get("battle_projection", {})
	var compact_projection: Dictionary = compact_variant as Dictionary if compact_variant is Dictionary else {}
	var battle_projection: Dictionary = battle_variant as Dictionary if battle_variant is Dictionary else {}

	toggle_button.visible = _overlay_mode == OverlayMode.COMPACT
	detail_root.visible = _overlay_mode == OverlayMode.BATTLE or _compact_expanded
	empty_hint_label.visible = false

	if _overlay_mode == OverlayMode.COMPACT:
		summary_title_label.text = str(compact_projection.get("summary_title", "旅途物资"))
		summary_text_label.text = str(compact_projection.get("summary_text", "遗物 0/0 · 药水 0/0"))
		summary_meta_label.text = str(compact_projection.get("summary_meta", ""))
		toggle_button.text = "收起详情" if _compact_expanded else str(compact_projection.get("toggle_text", "展开详情"))
		if _compact_expanded:
			_render_detail(battle_projection)
			empty_hint_label.visible = bool(compact_projection.get("show_empty_hint", false))
			empty_hint_label.text = str(compact_projection.get("empty_hint", "当前没有遗物或药水。"))
	else:
		summary_title_label.text = "战斗 HUD"
		summary_text_label.text = str(compact_projection.get("summary_text", "遗物 0/0 · 药水 0/0"))
		summary_meta_label.text = "保持悬停查看详情，药水操作仅在战斗内可用。"
		_render_detail(battle_projection)


func _render_detail(projection: Dictionary) -> void:
	relic_label.text = str(projection.get("relic_title", "遗物 0/0"))
	potion_label.text = str(projection.get("potion_title", "药水 0/0"))
	log_label.text = str(projection.get("log_text", "等待新的战斗日志……"))
	_render_relics(projection)
	_render_potions(projection)


func _render_relics(projection: Dictionary) -> void:
	for child in relic_list_label.get_children():
		child.queue_free()

	var relic_items: Variant = projection.get("relic_items", [])
	if not (relic_items is Array) or relic_items.is_empty():
		var hint := Label.new()
		hint.text = "（无遗物）"
		hint.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_SMALL)
		hint.modulate = UIColors.TEXT_MUTED
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
		btn.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_BODY)
		var tooltip_title := str(item_data.get("tooltip_title", btn.text))
		var tooltip_body := str(item_data.get("tooltip_body", ""))
		var tooltip_icon: Texture = item_data.get("tooltip_icon")
		if tooltip_body.length() > 0 or tooltip_title.length() > 0:
			btn.mouse_entered.connect(_emit_tooltip.bind("relic", tooltip_title, tooltip_body, tooltip_icon, UIColors.TOOLTIP_RELIC, "relic:%s" % tooltip_title))
			btn.mouse_exited.connect(_on_tooltip_mouse_exited)
		relic_list_label.add_child(btn)


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
			btn.text = str(button_data.get("text", "药水"))
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.disabled = not bool(button_data.get("enabled", true))
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn.pressed.connect(_on_use_potion.bind(index))
			var tooltip_title := str(button_data.get("tooltip_title", btn.text))
			var tooltip_body := str(button_data.get("tooltip_body", ""))
			var tooltip_icon: Texture = button_data.get("tooltip_icon")
			if tooltip_body.length() > 0 or tooltip_title.length() > 0:
				btn.mouse_entered.connect(_emit_tooltip.bind("potion", tooltip_title, tooltip_body, tooltip_icon, UIColors.TOOLTIP_POTION, "potion:%d" % index))
				btn.mouse_exited.connect(_on_tooltip_mouse_exited)
			potion_container.add_child(btn)

	if bool(projection.get("show_empty_potion_hint", false)):
		var hint := Label.new()
		hint.text = str(projection.get("empty_potion_hint", "（无可用药水）"))
		hint.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_SMALL)
		hint.modulate = UIColors.TEXT_MUTED
		potion_container.add_child(hint)

	if bool(projection.get("battle_only_hint_visible", false)):
		var battle_hint := Label.new()
		battle_hint.text = str(projection.get("battle_only_hint", "药水仅可在战斗中使用。"))
		battle_hint.add_theme_font_size_override("font_size", UILayout.FONT_SIZE_SMALL)
		battle_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		battle_hint.modulate = UIColors.WARNING
		potion_container.add_child(battle_hint)


func _on_use_potion(index: int) -> void:
	_adapter.use_potion(index)


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


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return
	var viewport_size := get_viewport_rect().size
	match _overlay_mode:
		OverlayMode.HIDDEN:
			hide()
		OverlayMode.COMPACT:
			UILayout.apply_overlay_compact_layout(self, viewport_size, _compact_expanded)
		OverlayMode.BATTLE:
			UILayout.apply_battle_hud_layout(self, viewport_size)
