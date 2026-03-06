class_name EnemyIntentRules
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")


static func pick_next_action(
	actions: Array[IntentActionData],
	last_action_name: StringName,
	_ascension_level: int,
	disallow_consecutive: bool,
	rng_stream_key: String = "enemy_intent"
) -> IntentActionData:
	var conditional := _collect_conditionals(actions)
	var weighted := _collect_weighted(actions)

	if conditional.size() > 0:
		return _pick_from_pool(
			conditional,
			last_action_name,
			disallow_consecutive,
			false,
			rng_stream_key
		)

	return _pick_from_pool(
		weighted,
		last_action_name,
		disallow_consecutive,
		true,
		rng_stream_key
	)


static func pick_first_conditional_action(
	actions: Array[IntentActionData],
	last_action_name: StringName,
	_ascension_level: int,
	disallow_consecutive: bool
) -> IntentActionData:
	var conditional := _collect_conditionals(actions)
	if conditional.size() == 0:
		return null

	return _pick_from_pool(
		conditional,
		last_action_name,
		disallow_consecutive,
		false,
		"enemy_intent_conditional"
	)


static func _pick_from_pool(
	pool: Array[IntentActionData],
	last_action_name: StringName,
	disallow_consecutive: bool,
	is_weighted: bool,
	rng_stream_key: String
) -> IntentActionData:
	if pool.size() == 0:
		return null

	var candidates := pool
	if disallow_consecutive:
		var filtered := _filter_no_repeat(candidates, last_action_name)
		if filtered.size() > 0:
			candidates = filtered

	if candidates.size() == 0:
		return null

	if not is_weighted:
		return candidates[0]

	return _pick_weighted(candidates, rng_stream_key)


static func _collect_conditionals(actions: Array[IntentActionData]) -> Array[IntentActionData]:
	var out: Array[IntentActionData] = []
	for action in actions:
		if action == null:
			continue
		if action.type != IntentActionData.ActionType.CONDITIONAL:
			continue
		if action.is_performable:
			out.append(action)
	return out


static func _collect_weighted(actions: Array[IntentActionData]) -> Array[IntentActionData]:
	var out: Array[IntentActionData] = []
	for action in actions:
		if action == null:
			continue
		if action.type != IntentActionData.ActionType.CHANCE_BASED:
			continue
		out.append(action)
	return out


static func _filter_no_repeat(
	actions: Array[IntentActionData],
	last_action_name: StringName
) -> Array[IntentActionData]:
	if last_action_name == &"":
		return actions

	var out: Array[IntentActionData] = []
	for action in actions:
		if action != null and action.action_name != last_action_name:
			out.append(action)
	return out


static func _pick_weighted(
	actions: Array[IntentActionData],
	rng_stream_key: String
) -> IntentActionData:
	var total := 0.0
	for action in actions:
		if action == null:
			continue
		total += maxf(0.0, action.effective_weight)

	if total <= 0.0:
		return actions[0] if actions.size() > 0 else null

	var stream_key: String = rng_stream_key if not rng_stream_key.is_empty() else "enemy_intent"
	var roll := RUN_RNG_SCRIPT.randf("%s:weighted_roll" % stream_key) * total
	var acc := 0.0
	for action in actions:
		if action == null:
			continue
		acc += maxf(0.0, action.effective_weight)
		if roll < acc:
			return action

	return actions[actions.size() - 1]
