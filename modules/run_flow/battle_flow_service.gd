class_name BattleFlowService
extends RefCounted

const REWARD_GENERATOR_SCRIPT := preload("res://modules/reward_economy/reward_generator.gd")
const SAVE_SERVICE_SCRIPT := preload("res://modules/persistence/save_service.gd")
const ROUTE_DISPATCHER_SCRIPT := preload("res://modules/run_flow/route_dispatcher.gd")

var route_dispatcher: RunRouteDispatcher


func _init(dispatcher: RunRouteDispatcher = null) -> void:
	route_dispatcher = dispatcher
	if route_dispatcher == null:
		route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher


func resolve_battle_completion(run_state: RunState, is_win: bool, reward_gold: int) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_MAP)

	if is_win:
		return _result(
			RunRouteDispatcher.ROUTE_REWARD,
			{
				"reward_gold": maxi(0, reward_gold),
			}
		)

	SAVE_SERVICE_SCRIPT.clear_save()
	return _result(
		RunRouteDispatcher.ROUTE_GAME_OVER,
		{
			"game_over_text": _build_game_over_text(run_state),
		}
	)


func apply_battle_reward(run_state: RunState, bundle: RewardBundle, chosen_card: Card) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_MAP)

	var reward_log := REWARD_GENERATOR_SCRIPT.apply_post_battle_reward(run_state, bundle, chosen_card)
	return _result(
		RunRouteDispatcher.ROUTE_MAP,
		{
			"reward_log": reward_log,
		}
	)


func _build_game_over_text(run_state: RunState) -> String:
	return "本次远征失败\n到达层数：%d\n最终金币：%d" % [run_state.floor + 1, run_state.gold]


func _result(next_route: String, payload: Dictionary = {}) -> Dictionary:
	return route_dispatcher.make_result(next_route, payload)
