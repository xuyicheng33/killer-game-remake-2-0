class_name RelicPotionUI
extends PanelContainer

const RELIC_POTION_UI_ADAPTER_SCRIPT := preload("res://modules/ui_shell/adapter/relic_potion_ui_adapter.gd")

@export var run_state: RunState : set = _set_run_state

@onready var relic_label: Label = %RelicLabel
@onready var relic_list_label: Label = %RelicListLabel
@onready var potion_label: Label = %PotionLabel
@onready var potion_container: VBoxContainer = %PotionContainer
@onready var log_label: Label = %LogLabel

var relic_potion_system: RelicPotionSystem : set = _set_relic_potion_system
var _adapter: RelicPotionUIAdapter = RELIC_POTION_UI_ADAPTER_SCRIPT.new() as RelicPotionUIAdapter


func _set_run_state(value: RunState) -> void:
	run_state = value
	_adapter.set_run_state(value)


func _set_relic_potion_system(value: RelicPotionSystem) -> void:
	relic_potion_system = value
	_adapter.set_relic_potion_system(value)


func _ready() -> void:
	if not _adapter.projection_changed.is_connected(_render):
		_adapter.projection_changed.connect(_render)
	_adapter.refresh()


func _on_use_potion(index: int) -> void:
	_adapter.use_potion(index)


func _render(projection: Dictionary) -> void:
	if not is_node_ready():
		return

	relic_label.text = str(projection.get("relic_title", "遗物 0/0"))
	relic_list_label.text = str(projection.get("relic_list_text", "（无）"))
	potion_label.text = str(projection.get("potion_title", "药水 0/0"))
	log_label.text = str(projection.get("log_text", ""))
	_render_potions(projection)


func _render_potions(projection: Dictionary) -> void:
	for child in potion_container.get_children():
		child.queue_free()

	var potion_buttons_variant: Variant = projection.get("potion_buttons", [])
	if potion_buttons_variant is Array:
		for button_variant in potion_buttons_variant:
			if not (button_variant is Dictionary):
				continue

			var button_data: Dictionary = button_variant
			var index := int(button_data.get("index", -1))
			if index < 0:
				continue

			var btn := Button.new()
			btn.text = str(button_data.get("text", "使用："))
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			btn.disabled = not bool(button_data.get("enabled", true))
			btn.pressed.connect(_on_use_potion.bind(index))
			potion_container.add_child(btn)

	if bool(projection.get("show_empty_potion_hint", false)):
		var hint := Label.new()
		hint.text = str(projection.get("empty_potion_hint", "（无可用药水）"))
		potion_container.add_child(hint)
