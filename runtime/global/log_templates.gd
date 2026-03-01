class_name LogTemplates

## 日志模板集中管理
## 统一格式便于维护和后续本地化

const TEMPLATES := {
	# === 遗物触发日志 ===
	# 战斗相关
	"relic_battle_start_heal": "%s 触发：战斗开始恢复 %d 生命",
	"relic_battle_end_heal": "%s 触发：战斗结束击杀 %d 敌人，恢复 %d 生命",

	# 回合相关
	"relic_turn_start_block": "%s 触发：回合开始获得 %d 格挡",
	"relic_turn_start_energy": "%s 触发：回合开始获得 %d 能量",
	"relic_turn_start_damage": "%s 触发：回合开始受到 %d 伤害",
	"relic_turn_end_heal": "%s 触发：回合结束恢复 %d 生命",

	# 出牌相关
	"relic_card_played_gold": "%s 触发：出牌后获得 %d 金币",
	"relic_attack_played_strength": "%s 触发：打出攻击牌获得 %d 力量",

	# 受击相关
	"relic_damage_taken_block": "%s 触发：受击后获得 %d 格挡",
	"relic_block_applied": "%s 触发：侦测到获得 %d 格挡",

	# 击杀相关
	"relic_enemy_killed_gold": "%s 触发：击杀敌人获得 %d 金币",
	"relic_enemy_killed_strength": "%s 触发：击杀敌人获得 %d 力量",
	"relic_enemy_killed_damage": "%s 触发：击杀敌人受到 %d 伤害",
	"relic_enemy_killed_draw": "%s 触发：击杀敌人抽 %d 张牌",
	"relic_boss_killed_gold": "%s 触发：击败 Boss 获得 %d 金币",

	# 商店相关
	"relic_shop_discount": "%s 生效：商店折扣 %d%%",

	# 开局相关
	"relic_run_start_gold": "%s 触发：开局获得 %d 金币",
	"relic_run_start_max_health": "%s 触发：开局最大生命 +%d",
	"relic_run_start_strength": "%s 触发：开局获得 %d 力量",

	# === 药水使用日志 ===
	"potion_heal": "使用 %s：恢复 %d 生命",
	"potion_gold": "使用 %s：获得 %d 金币",
	"potion_block": "使用 %s：获得 %d 格挡",
	"potion_damage_all": "使用 %s：对所有敌人造成 %d 伤害",
	"potion_no_target": "使用 %s：战斗外无有效目标",
	"potion_no_effect": "使用 %s：无效果",
	"potion_battle_only": "药水仅可在战斗中使用",

	# === 系统日志 ===
	"system_ready": "遗物/药水系统已就绪。",
}


## 格式化日志模板
## @param template_key: 模板键名
## @param args: 格式化参数数组
## @return: 格式化后的日志字符串
static func format(template_key: String, args: Array = []) -> String:
	var template: String = TEMPLATES.get(template_key, "%s")
	match args.size():
		0:
			return template
		1:
			return template % args[0]
		2:
			return template % [args[0], args[1]]
		3:
			return template % [args[0], args[1], args[2]]
		_:
			return template % args


## 快捷方法：格式化遗物触发日志
static func relic(relic_title: String, template_key: String, value: int = 0) -> String:
	return format(template_key, [relic_title, value])


## 快捷方法：格式化遗物触发日志（双参数）
static func relic_dual(relic_title: String, template_key: String, value1: int, value2: int) -> String:
	return format(template_key, [relic_title, value1, value2])


## 快捷方法：格式化药水日志
static func potion(potion_title: String, template_key: String, value: int = 0) -> String:
	return format(template_key, [potion_title, value])
