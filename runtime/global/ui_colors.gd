class_name UIColors
extends RefCounted

# === Core Palette ===
const PRIMARY := Color("e5ce86")
const PRIMARY_LIGHT := Color("f3e4b3")
const PRIMARY_DARK := Color("8a7a51")
const SECONDARY := Color("4cc9f0")
const SECONDARY_DARK := Color("2e7a92")
const ACCENT := Color("f48c06")

# === Background ===
const BG_DARK := Color(0.027451, 0.0352941, 0.0588235, 1)
const BG_PANEL := Color(0.039, 0.055, 0.086, 0.86)
const BG_OVERLAY := Color(0.0, 0.0, 0.0, 0.65)

# === Text ===
const TEXT_DEFAULT := Color(0.933, 0.941, 0.953, 1)
const TEXT_MUTED := Color(0.667, 0.682, 0.722, 0.8)
const TEXT_HIGHLIGHT := Color(1.0, 0.976, 0.875, 1.0)

# === Semantic ===
const SUCCESS := Color("90be6d")
const WARNING := Color("f9c74f")
const DANGER := Color("ff6b6b")
const INFO := Color("4cc9f0")

# === HP Bar ===
const HP_GREEN := Color("6bbd5b")
const HP_YELLOW := Color("f9c74f")
const HP_RED := Color("e74c3c")

# === Map node type ===
const NODE_BATTLE := Color("ffffff")
const NODE_ELITE := Color("f9c74f")
const NODE_REST := Color("90be6d")
const NODE_EVENT := Color("4cc9f0")
const NODE_SHOP := Color("b8a06e")
const NODE_BOSS := Color("ff6b6b")

# === Card UI ===
const CARD_COST_UNPLAYABLE := Color(1.0, 0.35, 0.35, 1.0)
const CARD_LABEL_DIMMED := Color(1, 1, 1, 0.55)
const CARD_ATTACK := Color("cc4444")
const CARD_SKILL := Color("4488cc")
const CARD_POWER := Color("cc8844")

# === Battle UI ===
const ZONE_COUNTS_TEXT := Color("dbe3f2")
const ENERGY_FULL := Color("e5ce86")
const ENERGY_EMPTY := Color("555555")
const BLOCK_ACTIVE := Color("5599dd")

# === Menu ===
const SAVE_EXISTS := Color(0.6, 0.9, 0.6)
const SAVE_MISSING := Color(0.7, 0.7, 0.7)

# === Borders ===
const BORDER_DEFAULT := Color(0.678, 0.596, 0.416, 0.72)
const BORDER_HIGHLIGHT := Color(0.898, 0.808, 0.525, 1.0)


static func hp_color_for_percent(percent: float) -> Color:
	if percent > 0.5:
		return HP_GREEN
	if percent > 0.25:
		return HP_YELLOW
	return HP_RED
