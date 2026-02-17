class_name RewardUIAdapter
extends RefCounted

signal projection_changed(projection: Dictionary)
signal reward_completed(bundle: RewardBundle, chosen_card: Card)

const REWARD_UI_VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/reward_ui_view_model.gd")
const REWARD_GENERATOR_SCRIPT := preload("res://runtime/modules/reward_economy/reward_generator.gd")

var _run_state: RunState
var _reward_gold: int = 0
var _bundle: RewardBundle
var _view_model: RewardUIViewModel = REWARD_UI_VIEW_MODEL_SCRIPT.new() as RewardUIViewModel


func set_run_state(value: RunState) -> void:
	_run_state = value


func set_reward_gold(value: int) -> void:
	_reward_gold = value


func generate_bundle() -> void:
	_bundle = REWARD_GENERATOR_SCRIPT.generate_post_battle_reward(_run_state, _reward_gold)
	refresh()


func refresh() -> void:
	var projection := _view_model.project(_bundle)
	projection_changed.emit(projection)


func select_card(card: Card) -> void:
	reward_completed.emit(_bundle, card)


func skip() -> void:
	reward_completed.emit(_bundle, null)


func apply_reward(chosen_card: Card) -> String:
	return REWARD_GENERATOR_SCRIPT.apply_post_battle_reward(_run_state, _bundle, chosen_card)
