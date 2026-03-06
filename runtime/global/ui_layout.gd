class_name UILayout
extends RefCounted

# === Font Sizes ===
const FONT_SIZE_SMALL := 18
const FONT_SIZE_BODY := 22
const FONT_SIZE_BUTTON := 22
const FONT_SIZE_BUTTON_LARGE := 24
const FONT_SIZE_ZONE_COUNTS := 20
const FONT_SIZE_STATUS_BADGE := 18

# === Button Min Heights ===
const BTN_HEIGHT_DEFAULT := 64
const BTN_HEIGHT_CARD := 76
const BTN_HEIGHT_MAP_NODE := 96

# === Responsive Layout ===
const MARGIN_H_RATIO := 0.04
const MARGIN_H_MIN := 18.0
const MARGIN_H_MAX := 140.0

const MARGIN_V_RATIO := 0.05
const MARGIN_V_MIN := 16.0
const MARGIN_V_MAX := 96.0

const OVERLAY_WIDTH_RATIO := 0.22
const OVERLAY_WIDTH_MIN := 260.0
const OVERLAY_WIDTH_MAX := 480.0

const CONTENT_MIN_WIDTH := 740.0

# === Spacing ===
const LIST_SEPARATION := 10


static func calc_h_margin(vw: float) -> float:
	return clampf(vw * MARGIN_H_RATIO, MARGIN_H_MIN, MARGIN_H_MAX)


static func calc_v_margin(vh: float) -> float:
	return clampf(vh * MARGIN_V_RATIO, MARGIN_V_MIN, MARGIN_V_MAX)


static func calc_overlay_width(vw: float) -> float:
	return clampf(vw * OVERLAY_WIDTH_RATIO, OVERLAY_WIDTH_MIN, OVERLAY_WIDTH_MAX)


static func apply_frame_layout(frame: Control, viewport_size: Vector2) -> void:
	var h_margin := calc_h_margin(viewport_size.x)
	var v_margin := calc_v_margin(viewport_size.y)
	var overlay_w := calc_overlay_width(viewport_size.x)

	frame.offset_left = h_margin
	frame.offset_top = v_margin
	frame.offset_right = -(h_margin + overlay_w)
	frame.offset_bottom = -v_margin

	var content_w := viewport_size.x + frame.offset_right - frame.offset_left
	if content_w < CONTENT_MIN_WIDTH:
		frame.offset_right = -h_margin
