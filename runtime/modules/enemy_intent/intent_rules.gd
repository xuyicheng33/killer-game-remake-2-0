class_name EnemyIntentRules
extends RefCounted

const RUN_RNG_SCRIPT := preload("res://runtime/global/run_rng.gd")

# Phase A / A5: Enemy intent rule layer.
# - Conditional actions have priority over chance-based actions.
# - Disallow consecutive actions when there is at least one alternative.
# - Ascension level is a placeholder parameter for future scaling.


static func pick_next_action(
	actions: Array[EnemyAction],
	last_action_name: StringName,
	ascension_level: int,
	disallow_consecutive: bool,
	rng_stream_key: String = "enemy_intent"
) -> EnemyAction:
	var conditional := _collect_conditionals(actions)
	var weighted := _collect_weighted(actions)

	if conditional.size() > 0:
		return _pick_from_pool(
			conditional,
			last_action_name,
			ascension_level,
			disallow_consecutive,
			false,
			rng_stream_key
		)

	return _pick_from_pool(
		weighted,
		last_action_name,
		ascension_level,
		disallow_consecutive,
		true,
		rng_stream_key
	)


static func pick_first_conditional_action(
	actions: Array[EnemyAction],
	last_action_name: StringName,
	ascension_level: int,
	disallow_consecutive: bool
) -> EnemyAction:
	var conditional := _collect_conditionals(actions)
	if conditional.size() == 0:
		return null

	return _pick_from_pool(
		conditional,
		last_action_name,
		ascension_level,
		disallow_consecutive,
		false,
		"enemy_intent_conditional"
	)


static func _pick_from_pool(
	pool: Array[EnemyAction],
	last_action_name: StringName,
	ascension_level: int,
	disallow_consecutive: bool,
	is_weighted: bool,
	rng_stream_key: String
) -> EnemyAction:
	if pool.size() == 0:
		return null

	var candidates := pool
	if disallow_consecutive:
		var filtered := _filter_no_repeat(candidates, last_action_name)
		# "No consecutive" is a soft constraint; don't allow it to make the pool empty.
		if filtered.size() > 0:
			candidates = filtered

	if candidates.size() == 0:
		return null

	if not is_weighted:
		# Conditional actions use stable ordering (node order as priority).
		return candidates[0]

	return _pick_weighted(candidates, ascension_level, rng_stream_key)


static func _collect_conditionals(actions: Array[EnemyAction]) -> Array[EnemyAction]:
	var out: Array[EnemyAction] = []
	for action in actions:
		if not action:
			continue
		if action.type != EnemyAction.Type.CONDITIONAL:
			continue
		if action.is_performable():
			out.append(action)
	return out


static func _collect_weighted(actions: Array[EnemyAction]) -> Array[EnemyAction]:
	var out: Array[EnemyAction] = []
	for action in actions:
		if not action:
			continue
		if action.type != EnemyAction.Type.CHANCE_BASED:
			continue
		out.append(action)
	return out


static func _filter_no_repeat(
	actions: Array[EnemyAction],
	last_action_name: StringName
) -> Array[EnemyAction]:
	if last_action_name == &"":
		return actions

	var out: Array[EnemyAction] = []
	for action in actions:
		if action and action.name != last_action_name:
			out.append(action)
	return out


static func _pick_weighted(
	actions: Array[EnemyAction],
	ascension_level: int,
	rng_stream_key: String
) -> EnemyAction:
	var total := 0.0
	for action in actions:
		if not action:
			continue
		total += maxf(0.0, action.get_effective_weight(ascension_level))

	# Defensive fallback: avoid division-by-zero / always-null selection.
	if total <= 0.0:
		return actions[0] if actions.size() > 0 else null

	var stream_key: String = rng_stream_key if not rng_stream_key.is_empty() else "enemy_intent"
	var roll := RUN_RNG_SCRIPT.randf("%s:weighted_roll" % stream_key) * total
	var acc := 0.0
	for action in actions:
		if not action:
			continue
		acc += maxf(0.0, action.get_effective_weight(ascension_level))
		if roll < acc:
			return action

	# In case of float rounding.
	return actions[actions.size() - 1]
