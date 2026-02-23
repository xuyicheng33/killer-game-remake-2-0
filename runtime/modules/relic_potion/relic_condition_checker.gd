class_name RelicConditionChecker

## 遗物条件检查器
## 将条件检查逻辑从效果执行中分离


## 检查间隔触发条件
## @param current_count: 当前计数
## @param interval: 触发间隔
## @return: 是否满足间隔条件
static func check_interval(current_count: int, interval: int) -> bool:
	if interval <= 0:
		return true
	var safe_interval := maxi(1, interval)
	return current_count % safe_interval == 0


## 检查触发次数限制
## @param system: 遗物系统实例
## @param relic_id: 遗物ID
## @param trigger_type: 触发类型标识
## @param max_triggers: 最大触发次数（0表示无限制）
## @return: 是否可以触发
static func can_trigger(system: Object, relic_id: String, trigger_type: String, max_triggers: int) -> bool:
	if max_triggers <= 0:
		return true
	if system == null:
		return false
	var current_count: int = system.get_relic_trigger_count(relic_id, trigger_type)
	return current_count < max_triggers


## 检查并消耗触发次数
## @param system: 遗物系统实例
## @param relic_id: 遗物ID
## @param trigger_type: 触发类型标识
## @param max_triggers: 最大触发次数（0表示无限制）
## @return: 是否成功消耗（即是否可以触发）
static func check_and_consume_trigger(
	system: Object,
	relic_id: String,
	trigger_type: String,
	max_triggers: int
) -> bool:
	if max_triggers <= 0:
		return true
	if system == null:
		return false

	var current_count: int = system.get_relic_trigger_count(relic_id, trigger_type)
	if current_count >= max_triggers:
		return false

	system.increment_relic_trigger_count(relic_id, trigger_type)
	return true


## 检查目标生命百分比是否低于阈值
## @param target: 目标对象（需要有 stats 属性）
## @param percent: 百分比阈值（0.0-1.0）
## @return: 是否低于阈值
static func check_hp_below_percent(target: Node, percent: float) -> bool:
	if target == null:
		return false
	if not "stats" in target:
		return false

	var stats = target.stats
	if stats == null:
		return false
	if not "health" in stats or not "max_health" in stats:
		return false

	return float(stats.health) / float(stats.max_health) <= percent
