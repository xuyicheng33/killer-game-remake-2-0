class_name IntentActionData
extends RefCounted

enum ActionType { CONDITIONAL, CHANCE_BASED }

var type: int
var action_name: StringName
var is_performable: bool
var effective_weight: float
var source_index: int


static func from_values(
	p_type: int,
	p_name: StringName,
	p_performable: bool,
	p_weight: float,
	p_index: int
) -> IntentActionData:
	var data := IntentActionData.new()
	data.type = p_type
	data.action_name = p_name
	data.is_performable = p_performable
	data.effective_weight = p_weight
	data.source_index = p_index
	return data
