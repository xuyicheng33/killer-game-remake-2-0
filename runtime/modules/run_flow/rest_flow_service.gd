class_name RestFlowService
extends RefCounted


func execute_rest(run_state: RunState) -> Dictionary:
	if run_state == null or run_state.player_stats == null:
		return _result(true, "")

	var recover := maxi(6, int(round(run_state.player_stats.max_health * 0.2)))
	run_state.heal_player(recover)
	run_state.next_floor()
	return _result(true, "")


func execute_upgrade(run_state: RunState) -> Dictionary:
	if run_state == null:
		return _result(true, "")

	var upgraded := run_state.upgrade_card_in_deck_at(0)
	if upgraded:
		run_state.next_floor()
		return _result(true, "升级成功：牌组第 1 张卡已强化。")

	# Keep old fallback behavior when upgrade cannot be applied.
	run_state.add_gold(5)
	run_state.next_floor()
	return _result(true, "当前无可升级卡，改为获得 5 金币。")


func _result(completed: bool, info_text: String) -> Dictionary:
	return {
		"completed": completed,
		"info_text": info_text,
	}
