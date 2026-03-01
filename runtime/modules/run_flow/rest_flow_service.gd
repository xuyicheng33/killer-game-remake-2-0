class_name RestFlowService
extends RefCounted

const ROUTE_DISPATCHER_SCRIPT := preload("res://runtime/modules/run_flow/route_dispatcher.gd")
const RUN_STATE_COMMAND_SERVICE_SCRIPT := preload("res://runtime/modules/run_meta/run_state_command_service.gd")

var route_dispatcher: RunRouteDispatcher
var _commands


func _init() -> void:
	route_dispatcher = ROUTE_DISPATCHER_SCRIPT.new() as RunRouteDispatcher
	_commands = RUN_STATE_COMMAND_SERVICE_SCRIPT.new()


func execute_rest(run_state: RunState) -> Dictionary:
	if run_state == null or run_state.player_stats == null:
		return _result(RunRouteDispatcher.ROUTE_REST, false, "当前状态无法休息。")

	var recover := maxi(6, int(round(run_state.player_stats.max_health * 0.2)))
	_commands.heal_player(run_state, recover)
	_commands.next_floor(run_state)
	return _result(RunRouteDispatcher.ROUTE_MAP, true, "")


func execute_upgrade(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _result(RunRouteDispatcher.ROUTE_REST, false, "当前状态无法强化。")

	var upgraded: bool = bool(_commands.upgrade_card_in_deck_at(run_state, 0))
	if upgraded:
		_commands.next_floor(run_state)
		return _result(RunRouteDispatcher.ROUTE_MAP, true, "升级成功：牌组第 1 张卡已强化。")

	# Keep old fallback behavior when upgrade cannot be applied.
	_commands.add_gold(run_state, 5)
	_commands.next_floor(run_state)
	return _result(RunRouteDispatcher.ROUTE_MAP, true, "当前无可升级卡，改为获得 5 金币。")


func _result(next_route: String, completed: bool, info_text: String) -> Dictionary:
	return route_dispatcher.make_result(next_route, {
		"completed": completed,
		"info_text": info_text,
	})
