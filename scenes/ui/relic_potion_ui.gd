class_name RelicPotionUI
extends PanelContainer

@export var run_state: RunState : set = _set_run_state

@onready var relic_label: Label = %RelicLabel
@onready var relic_list_label: Label = %RelicListLabel
@onready var potion_label: Label = %PotionLabel
@onready var potion_container: VBoxContainer = %PotionContainer
@onready var log_label: Label = %LogLabel

var relic_potion_system: RelicPotionSystem : set = _set_relic_potion_system


func _set_run_state(value: RunState) -> void:
	if run_state and run_state.changed.is_connected(_refresh):
		run_state.changed.disconnect(_refresh)

	run_state = value
	if run_state and not run_state.changed.is_connected(_refresh):
		run_state.changed.connect(_refresh)
	_refresh()


func _set_relic_potion_system(value: RelicPotionSystem) -> void:
	if relic_potion_system and relic_potion_system.log_updated.is_connected(_on_log_updated):
		relic_potion_system.log_updated.disconnect(_on_log_updated)

	relic_potion_system = value
	if relic_potion_system and not relic_potion_system.log_updated.is_connected(_on_log_updated):
		relic_potion_system.log_updated.connect(_on_log_updated)


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return

	if run_state == null:
		relic_label.text = "遗物 0/0"
		relic_list_label.text = "（无）"
		potion_label.text = "药水 0/0"
		_render_potions()
		return

	relic_label.text = "遗物 %d/%d" % [run_state.relics.size(), run_state.relic_capacity]
	potion_label.text = "药水 %d/%d" % [run_state.potions.size(), run_state.potion_capacity]

	var relic_names: PackedStringArray = []
	for relic in run_state.relics:
		var relic_data := relic as RelicData
		if relic_data == null:
			continue
		relic_names.append(relic_data.title)
	relic_list_label.text = ", ".join(relic_names) if not relic_names.is_empty() else "（无）"
	_render_potions()


func _render_potions() -> void:
	for child in potion_container.get_children():
		child.queue_free()

	if run_state == null:
		return

	for i in range(run_state.potions.size()):
		var potion := run_state.potions[i] as PotionData
		var btn := Button.new()
		btn.text = "使用：%s" % _potion_name(potion)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_use_potion.bind(i))
		potion_container.add_child(btn)

	if run_state.potions.is_empty():
		var hint := Label.new()
		hint.text = "（无可用药水）"
		potion_container.add_child(hint)


func _on_use_potion(index: int) -> void:
	if relic_potion_system == null:
		return
	relic_potion_system.use_potion(index)
	_refresh()


func _on_log_updated(text: String) -> void:
	log_label.text = text
	_refresh()


func _potion_name(potion: PotionData) -> String:
	if potion == null:
		return "(无效药水)"
	return potion.title

