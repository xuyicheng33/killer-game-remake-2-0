class_name GameEffectExecutor

## 统一效果执行器
## 整合卡牌、遗物、药水的效果执行逻辑

const LOG_TEMPLATES := preload("res://runtime/global/log_templates.gd")


## 效果类型枚举
enum EffectType {
	HEAL,
	DAMAGE,
	BLOCK,
	ADD_GOLD,
	ADD_ENERGY,
	DRAW,
	APPLY_STATUS,
	TAKE_DAMAGE,
	ADD_STRENGTH,
	INCREASE_MAX_HEALTH,
}


## 统一效果执行入口
## @param effect_type: 效果类型字符串
## @param value: 效果数值
## @param context: 上下文字典，包含 run_state, player_stats, effect_stack, targets, source_name 等
static func execute(effect_type: String, value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		push_warning("[GameEffectExecutor] run_state 为空，效果无法执行: %s" % effect_type)
		return

	var safe_value := maxi(0, value) if effect_type != "take_damage" else value

	match effect_type:
		"heal":
			apply_heal(safe_value, context)
		"damage":
			apply_damage(safe_value, context)
		"block", "add_block":
			apply_block(safe_value, context)
		"add_gold":
			add_gold(safe_value, context)
		"add_energy":
			add_energy(safe_value, context)
		"draw", "draw_cards":
			draw_cards(safe_value, context)
		"apply_status":
			var status_id: String = context.get("status_id", "")
			var stacks: int = context.get("stacks", 1)
			apply_status(status_id, stacks, context)
		"take_damage":
			apply_self_damage(safe_value, context)
		"add_strength":
			add_strength(safe_value, context)
		"increase_max_health":
			increase_max_health(safe_value, context)
		_:
			push_warning("[GameEffectExecutor] 未知效果类型: %s" % effect_type)


## 恢复生命
static func apply_heal(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	run_state.heal_player(value)


## 造成伤害（对目标）
static func apply_damage(value: int, context: Dictionary) -> void:
	var targets: Array = context.get("targets", [])
	var battle_context = context.get("battle_context")

	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		if target.has_method("take_damage"):
			target.call("take_damage", value)


## 获得格挡
static func apply_block(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	if run_state.player_stats == null:
		return

	var block_gain := maxi(0, value)
	run_state.player_stats.block += block_gain
	if block_gain > 0:
		var source: String = context.get("source_name", "game_effect")
		Events.player_block_applied.emit(block_gain, source)
	run_state.emit_changed()


## 获得金币
static func add_gold(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	run_state.add_gold(value)


## 获得能量
static func add_energy(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	if run_state.player_stats == null:
		return

	var char_stats: CharacterStats = run_state.player_stats
	char_stats.mana = mini(char_stats.mana + value, char_stats.max_mana)
	run_state.emit_changed()


## 抽牌
static func draw_cards(value: int, context: Dictionary) -> void:
	if value <= 0:
		return

	var battle_context = context.get("battle_context")
	if context.has("draw_callable"):
		var draw_callable_variant: Variant = context["draw_callable"]
		if typeof(draw_callable_variant) == TYPE_CALLABLE:
			draw_callable_variant.call(value)
			return

	if battle_context != null and battle_context.has_method("draw_cards"):
		battle_context.draw_cards(value)


## 应用状态效果
static func apply_status(status_id: String, stacks: int, context: Dictionary) -> void:
	if status_id.is_empty():
		return

	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	if run_state.player_stats == null:
		return

	run_state.player_stats.add_status(status_id, stacks)


## 自身受到伤害
static func apply_self_damage(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	if run_state.player_stats == null:
		return

	var damage := maxi(0, value)
	if damage <= 0:
		return

	var stats: CharacterStats = run_state.player_stats
	var initial_health := stats.health
	stats.take_damage(damage)

	var battle_active: bool = context.get("battle_active", false)
	if battle_active and initial_health > 0 and stats.health <= 0:
		Events.player_died.emit()


## 获得力量
static func add_strength(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	if run_state.player_stats == null:
		return

	run_state.player_stats.add_status("strength", value)


## 增加最大生命
static func increase_max_health(value: int, context: Dictionary) -> void:
	var run_state: RunState = context.get("run_state")
	if run_state == null:
		return
	run_state.increase_max_health(value)
