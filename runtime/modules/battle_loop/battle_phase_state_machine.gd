class_name BattlePhaseStateMachine
extends RefCounted

enum Phase {
	INVALID = -1,
	DRAW,
	ACTION,
	ENEMY,
	RESOLVE,
}

signal phase_changed(from_phase: Phase, to_phase: Phase, turn: int)

var _phase: Phase = Phase.INVALID
var _turn := 0


func get_phase() -> Phase:
	return _phase


func get_turn() -> int:
	return _turn


func start() -> void:
	_turn = 1
	_transition_to_internal(Phase.DRAW)


func can_transition(to_phase: Phase) -> bool:
	match _phase:
		Phase.INVALID:
			return to_phase == Phase.DRAW
		Phase.DRAW:
			return to_phase == Phase.ACTION
		Phase.ACTION:
			return to_phase == Phase.ENEMY
		Phase.ENEMY:
			return to_phase == Phase.RESOLVE
		Phase.RESOLVE:
			return to_phase == Phase.DRAW
		_:
			return false


func transition_to(to_phase: Phase) -> bool:
	if not can_transition(to_phase):
		return false

	if _phase == Phase.RESOLVE and to_phase == Phase.DRAW:
		_turn += 1

	_transition_to_internal(to_phase)
	return true


func get_phase_name(phase: Phase = _phase) -> String:
	match phase:
		Phase.DRAW:
			return "DRAW"
		Phase.ACTION:
			return "ACTION"
		Phase.ENEMY:
			return "ENEMY"
		Phase.RESOLVE:
			return "RESOLVE"
		_:
			return "INVALID"


func _transition_to_internal(to_phase: Phase) -> void:
	var from_phase := _phase
	_phase = to_phase
	phase_changed.emit(from_phase, to_phase, _turn)
