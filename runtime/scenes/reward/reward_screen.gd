class_name RewardScreen
extends Control

signal reward_completed(bundle: RewardBundle, chosen_card: Card)

const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")

@export var run_state: RunState
@export var reward_gold: int = 0

@onready var frame: PanelContainer = %Frame
@onready var gold_label: Label = %GoldLabel
@onready var extra_reward_label: Label = %ExtraRewardLabel
@onready var cards_container: VBoxContainer = %CardsContainer
@onready var skip_button: Button = %SkipButton

var _bundle: RewardBundle


func _ready() -> void:
	_apply_responsive_layout()
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_resized):
		viewport.size_changed.connect(_on_viewport_resized)

	skip_button.pressed.connect(_on_skip_pressed)
	_refresh()


func _refresh() -> void:
	_bundle = REWARD_GENERATOR_SCRIPT.generate_post_battle_reward(run_state, reward_gold)

	gold_label.text = "金币：+%d" % _bundle.gold
	extra_reward_label.text = _format_extra_rewards(_bundle)

	for child in cards_container.get_children():
		child.queue_free()

	if _bundle.card_choices.is_empty():
		var hint := Label.new()
		hint.text = "当前无卡牌奖励，可直接继续前进。"
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_font_size_override("font_size", 22)
		cards_container.add_child(hint)
		return

	for card in _bundle.card_choices:
		var btn := Button.new()
		btn.text = _format_card_label(card)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 76)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(_on_card_pressed.bind(card))
		if card != null and card.tooltip_text.length() > 0:
			btn.tooltip_text = card.tooltip_text
		cards_container.add_child(btn)


func _format_card_label(card: Card) -> String:
	if card == null:
		return "(null card)"
	return "%s  [费:%s]" % [card.id, card.get_cost_label()]


func _format_extra_rewards(bundle: RewardBundle) -> String:
	if bundle == null:
		return "额外奖励：无"

	var parts: PackedStringArray = []
	if bundle.relic_reward != null:
		parts.append("遗物：%s" % bundle.relic_reward.title)
	if bundle.potion_reward != null:
		parts.append("药水：%s" % bundle.potion_reward.title)
	if parts.is_empty():
		return "额外奖励：无"
	return "额外奖励：" + " / ".join(parts)


func _on_card_pressed(card: Card) -> void:
	reward_completed.emit(_bundle, card)


func _on_skip_pressed() -> void:
	reward_completed.emit(_bundle, null)


func _on_viewport_resized() -> void:
	_apply_responsive_layout()


func _apply_responsive_layout() -> void:
	if not is_node_ready():
		return

	var viewport_size := get_viewport_rect().size
	var horizontal_margin := clampf(viewport_size.x * 0.045, 18.0, 150.0)
	var vertical_margin := clampf(viewport_size.y * 0.05, 16.0, 96.0)
	var reserved_overlay_width := clampf(viewport_size.x * 0.23, 280.0, 460.0)

	frame.offset_left = horizontal_margin
	frame.offset_top = vertical_margin
	frame.offset_right = -(horizontal_margin + reserved_overlay_width)
	frame.offset_bottom = -vertical_margin

	var content_width := viewport_size.x + frame.offset_right - frame.offset_left
	if content_width < 720.0:
		frame.offset_right = -horizontal_margin
