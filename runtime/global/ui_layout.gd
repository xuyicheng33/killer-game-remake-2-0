class_name UILayout
extends RefCounted

# === Font Sizes ===
const FONT_SIZE_SMALL := 16
const FONT_SIZE_BODY := 20
const FONT_SIZE_BUTTON := 20
const FONT_SIZE_BUTTON_LARGE := 24
const FONT_SIZE_ZONE_COUNTS := 18
const FONT_SIZE_STATUS_BADGE := 16
const FONT_SIZE_HUD_TITLE := 26
const FONT_SIZE_HUD_META := 14

# === Button Min Heights ===
const BTN_HEIGHT_DEFAULT := 62
const BTN_HEIGHT_CARD := 84
const BTN_HEIGHT_MAP_NODE := 104
const BTN_HEIGHT_PRIMARY := 76

# === Screen Frame ===
const SCREEN_MARGIN_H_RATIO := 0.045
const SCREEN_MARGIN_H_MIN := 42.0
const SCREEN_MARGIN_H_MAX := 132.0
const SCREEN_MARGIN_V_RATIO := 0.055
const SCREEN_MARGIN_V_MIN := 30.0
const SCREEN_MARGIN_V_MAX := 110.0
const SCREEN_GAP := 14

# === Overlay ===
const HUD_MARGIN := 18.0
const COMPACT_DOCK_WIDTH_MIN := 220.0
const COMPACT_DOCK_WIDTH_MAX := 360.0
const COMPACT_DOCK_COLLAPSED_HEIGHT := 88.0
const COMPACT_DOCK_EXPANDED_HEIGHT_MIN := 240.0
const COMPACT_DOCK_EXPANDED_HEIGHT_MAX := 520.0
const BATTLE_DOCK_WIDTH_MIN := 300.0
const BATTLE_DOCK_WIDTH_MAX := 420.0
const BATTLE_DOCK_HEIGHT_RATIO := 0.68
const BATTLE_DOCK_HEIGHT_MIN := 420.0
const BATTLE_DOCK_HEIGHT_MAX := 780.0

# === Battle Layout ===
const BATTLE_PHASE_WIDTH_MIN := 260.0
const BATTLE_PHASE_WIDTH_MAX := 420.0
const BATTLE_PHASE_HEIGHT_MIN := 108.0
const BATTLE_PHASE_HEIGHT_MAX := 180.0
const BATTLE_ZONE_WIDTH_MIN := 260.0
const BATTLE_ZONE_WIDTH_MAX := 420.0
const BATTLE_ZONE_HEIGHT := 84.0
const BATTLE_HAND_WIDTH_RATIO := 0.52
const BATTLE_HAND_WIDTH_MIN := 760.0
const BATTLE_HAND_WIDTH_MAX := 1180.0
const BATTLE_HAND_TOP_RATIO := 0.24
const BATTLE_HAND_TOP_MIN := 176.0
const BATTLE_HAND_TOP_MAX := 286.0
const BATTLE_ACTION_WIDTH_MIN := 188.0
const BATTLE_ACTION_WIDTH_MAX := 300.0
const BATTLE_ACTION_HEIGHT_MIN := 64.0
const BATTLE_ACTION_HEIGHT_MAX := 92.0
const MANA_PANEL_SIZE := Vector2(168, 86)

# === Spacing ===
const LIST_SEPARATION := 10


static func calc_screen_h_margin(vw: float) -> float:
	return clampf(vw * SCREEN_MARGIN_H_RATIO, SCREEN_MARGIN_H_MIN, SCREEN_MARGIN_H_MAX)


static func calc_screen_v_margin(vh: float) -> float:
	return clampf(vh * SCREEN_MARGIN_V_RATIO, SCREEN_MARGIN_V_MIN, SCREEN_MARGIN_V_MAX)


static func apply_screen_frame_layout(frame: Control, viewport_size: Vector2) -> void:
	if frame == null:
		return
	var h_margin := calc_screen_h_margin(viewport_size.x)
	var v_margin := calc_screen_v_margin(viewport_size.y)
	frame.anchors_preset = 15
	frame.anchor_left = 0.0
	frame.anchor_top = 0.0
	frame.anchor_right = 1.0
	frame.anchor_bottom = 1.0
	frame.offset_left = h_margin
	frame.offset_top = v_margin
	frame.offset_right = -h_margin
	frame.offset_bottom = -v_margin


static func apply_overlay_compact_layout(panel: Control, viewport_size: Vector2, expanded: bool) -> void:
	if panel == null:
		return
	var margin := clampf(viewport_size.x * 0.012, HUD_MARGIN, 30.0)
	var width := clampf(viewport_size.x * 0.16, COMPACT_DOCK_WIDTH_MIN, COMPACT_DOCK_WIDTH_MAX)
	var height := COMPACT_DOCK_COLLAPSED_HEIGHT
	if expanded:
		height = clampf(viewport_size.y * 0.42, COMPACT_DOCK_EXPANDED_HEIGHT_MIN, COMPACT_DOCK_EXPANDED_HEIGHT_MAX)
	panel.anchors_preset = 1
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -(width + margin)
	panel.offset_top = margin
	panel.offset_right = -margin
	panel.offset_bottom = margin + height


static func apply_battle_hud_layout(panel: Control, viewport_size: Vector2) -> void:
	if panel == null:
		return
	var margin := clampf(viewport_size.x * 0.012, HUD_MARGIN, 30.0)
	var width := clampf(viewport_size.x * 0.19, BATTLE_DOCK_WIDTH_MIN, BATTLE_DOCK_WIDTH_MAX)
	var height := clampf(viewport_size.y * BATTLE_DOCK_HEIGHT_RATIO, BATTLE_DOCK_HEIGHT_MIN, BATTLE_DOCK_HEIGHT_MAX)
	panel.anchors_preset = 3
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -(width + margin)
	panel.offset_top = margin
	panel.offset_right = -margin
	panel.offset_bottom = margin + height


static func apply_modal_layout(panel: Control, viewport_size: Vector2) -> void:
	if panel == null:
		return
	var width := clampf(viewport_size.x * 0.44, 520.0, 940.0)
	var height := clampf(viewport_size.y * 0.52, 320.0, 620.0)
	panel.anchors_preset = 8
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -width * 0.5
	panel.offset_top = -height * 0.5
	panel.offset_right = width * 0.5
	panel.offset_bottom = height * 0.5


static func apply_battle_hand_layout(hand: Control, viewport_size: Vector2) -> void:
	if hand == null:
		return
	var width := clampf(viewport_size.x * BATTLE_HAND_WIDTH_RATIO, BATTLE_HAND_WIDTH_MIN, BATTLE_HAND_WIDTH_MAX)
	var top := -clampf(viewport_size.y * BATTLE_HAND_TOP_RATIO, BATTLE_HAND_TOP_MIN, BATTLE_HAND_TOP_MAX)
	hand.offset_left = -width * 0.5
	hand.offset_right = width * 0.5
	hand.offset_top = top


static func apply_battle_primary_action_layout(button: Control, viewport_size: Vector2) -> void:
	if button == null:
		return
	var right_margin := clampf(viewport_size.x * 0.018, 22.0, 36.0)
	var bottom_margin := clampf(viewport_size.y * 0.025, 18.0, 34.0)
	var width := clampf(viewport_size.x * 0.12, BATTLE_ACTION_WIDTH_MIN, BATTLE_ACTION_WIDTH_MAX)
	var height := clampf(viewport_size.y * 0.085, BATTLE_ACTION_HEIGHT_MIN, BATTLE_ACTION_HEIGHT_MAX)
	button.offset_left = -(width + right_margin)
	button.offset_top = -(height + bottom_margin)
	button.offset_right = -right_margin
	button.offset_bottom = -bottom_margin


static func apply_battle_phase_panel_layout(panel: Control, viewport_size: Vector2) -> void:
	if panel == null:
		return
	var margin := clampf(viewport_size.x * 0.012, 18.0, 28.0)
	var width := clampf(viewport_size.x * 0.22, BATTLE_PHASE_WIDTH_MIN, BATTLE_PHASE_WIDTH_MAX)
	var height := clampf(viewport_size.y * 0.17, BATTLE_PHASE_HEIGHT_MIN, BATTLE_PHASE_HEIGHT_MAX)
	panel.offset_left = margin
	panel.offset_top = margin
	panel.offset_right = margin + width
	panel.offset_bottom = margin + height


static func apply_battle_zone_panel_layout(panel: Control, viewport_size: Vector2) -> void:
	if panel == null:
		return
	var margin := clampf(viewport_size.x * 0.012, 18.0, 28.0)
	var width := clampf(viewport_size.x * 0.24, BATTLE_ZONE_WIDTH_MIN, BATTLE_ZONE_WIDTH_MAX)
	panel.anchors_preset = 1
	panel.anchor_left = 1.0
	panel.anchor_top = 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -(width + margin)
	panel.offset_top = margin
	panel.offset_right = -margin
	panel.offset_bottom = margin + BATTLE_ZONE_HEIGHT


static func apply_mana_panel_layout(panel: Control, viewport_size: Vector2) -> void:
	if panel == null:
		return
	var margin := clampf(viewport_size.x * 0.012, 18.0, 28.0)
	panel.anchors_preset = 0
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = margin
	panel.offset_top = clampf(viewport_size.y * 0.18, 120.0, 180.0)
	panel.offset_right = margin + MANA_PANEL_SIZE.x
	panel.offset_bottom = clampf(viewport_size.y * 0.18, 120.0, 180.0) + MANA_PANEL_SIZE.y


static func apply_frame_layout(frame: Control, viewport_size: Vector2) -> void:
	apply_screen_frame_layout(frame, viewport_size)


static func apply_zone_panel_layout(panel: Control, viewport_size: Vector2) -> void:
	apply_battle_zone_panel_layout(panel, viewport_size)
