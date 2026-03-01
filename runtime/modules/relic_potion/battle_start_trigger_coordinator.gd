class_name BattleStartTriggerCoordinator
extends RefCounted

enum Action {
	NOOP,
	DEFER_CHECK,
	COMPLETE,
	ABORT,
	SCHEDULE_RETRY,
}


func evaluate_immediate(
	pending_trigger: bool,
	battle_active: bool,
	context_ready: bool
) -> Action:
	if not pending_trigger:
		return Action.NOOP
	if not battle_active:
		return Action.ABORT
	if context_ready:
		return Action.COMPLETE
	return Action.DEFER_CHECK


func evaluate_deferred(
	pending_trigger: bool,
	battle_active: bool,
	context_ready: bool,
	retry_count: int,
	max_retries: int
) -> Dictionary:
	if not pending_trigger:
		return {
			"action": Action.NOOP,
			"retry_count": retry_count,
			"timed_out": false,
		}
	if not battle_active:
		return {
			"action": Action.ABORT,
			"retry_count": retry_count,
			"timed_out": false,
		}
	if context_ready:
		return {
			"action": Action.COMPLETE,
			"retry_count": retry_count,
			"timed_out": false,
		}

	var next_retry_count := retry_count + 1
	if next_retry_count > max_retries:
		return {
			"action": Action.ABORT,
			"retry_count": next_retry_count,
			"timed_out": true,
		}
	return {
		"action": Action.SCHEDULE_RETRY,
		"retry_count": next_retry_count,
		"timed_out": false,
	}
