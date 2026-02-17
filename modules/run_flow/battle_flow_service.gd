class_name BattleFlowService
extends RefCounted

const REWARD_GENERATOR_SCRIPT := preload("res://modules/reward_economy/reward_generator.gd")
const SAVE_SERVICE_SCRIPT := preload("res://modules/persistence/save_service.gd")

const ROUTE_REWARD := "reward"
const ROUTE_GAME_OVER := "game_over"
const ROUTE_MAP := "map"


func resolve_battle_completion(run_state: RunState, is_win: bool, reward_gold: int) -> Dictionary:
	if run_state == null:
		return _result(ROUTE_MAP)

	if is_win:
		return _result(
			ROUTE_REWARD,
			{
				"reward_gold": maxi(0, reward_gold),
			}
		)

	SAVE_SERVICE_SCRIPT.clear_save()
	return _result(
		ROUTE_GAME_OVER,
		{
			"game_over_text": _build_game_over_text(run_state),
		}
	)


func apply_battle_reward(run_state: RunState, bundle: RewardBundle, chosen_card: Card) -> Dictionary:
	if run_state == null:
		return _result(ROUTE_MAP)

	var reward_log := REWARD_GENERATOR_SCRIPT.apply_post_battle_reward(run_state, bundle, chosen_card)
	return _result(
		ROUTE_MAP,
		{
			"reward_log": reward_log,
		}
	)


func _build_game_over_text(run_state: RunState) -> String:
	return "本次远征失败\n到达层数：%d\n最终金币：%d" % [run_state.floor + 1, run_state.gold]


func _result(next_route: String, payload: Dictionary = {}) -> Dictionary:
	var out := {
		"next_route": next_route,
	}
	for key in payload.keys():
		out[key] = payload[key]
	return out
