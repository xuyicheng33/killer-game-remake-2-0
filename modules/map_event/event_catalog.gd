class_name EventCatalog
extends RefCounted

# B3 minimum: 10 baseline event templates.
const TEMPLATES: Array[Dictionary] = [
	{
		"id": "event_gold_shrine",
		"title": "金色祭坛",
		"description": "你发现一座镶着硬币的祭坛。",
		"options": [
			{"label": "祈祷（+25 金币）", "effect": "gold", "value": 25},
			{"label": "献祭（失去 5 生命，+45 金币）", "effect": "gold_for_hp", "gold": 45, "hp": 5},
		],
	},
	{
		"id": "event_forgotten_well",
		"title": "被遗忘的井",
		"description": "井底有微弱反光。",
		"options": [
			{"label": "取水（回复 8 生命）", "effect": "heal", "value": 8},
			{"label": "向下探索（失去 7 生命，获得 1 张牌）", "effect": "add_card_for_hp", "hp": 7},
		],
	},
	{
		"id": "event_old_merchant",
		"title": "旧商旅",
		"description": "商人愿意低价交换一件货物。",
		"options": [
			{"label": "支付 20 金币，获得 1 张牌", "effect": "buy_card", "cost": 20},
			{"label": "拒绝（无事发生）", "effect": "none"},
		],
	},
	{
		"id": "event_training_dummy",
		"title": "训练假人",
		"description": "一排木桩上刻着古老招式。",
		"options": [
			{"label": "练习（升级 1 张牌）", "effect": "upgrade_card"},
			{"label": "拆掉木桩（+12 金币）", "effect": "gold", "value": 12},
		],
	},
	{
		"id": "event_blood_alley",
		"title": "血色小巷",
		"description": "地上有尚未干涸的血迹。",
		"options": [
			{"label": "强闯（失去 8 生命，+35 金币）", "effect": "gold_for_hp", "gold": 35, "hp": 8},
			{"label": "绕行（失去 8 金币）", "effect": "gold", "value": -8},
		],
	},
	{
		"id": "event_mirror_room",
		"title": "镜像房间",
		"description": "镜中倒影似乎在嘲笑你。",
		"options": [
			{"label": "打碎镜子（失去 4 生命，升级 1 张牌）", "effect": "upgrade_for_hp", "hp": 4},
			{"label": "平静离开（回复 4 生命）", "effect": "heal", "value": 4},
		],
	},
	{
		"id": "event_abandoned_cache",
		"title": "废弃补给箱",
		"description": "箱子里混杂着金币和破损卡片。",
		"options": [
			{"label": "翻找（+18 金币）", "effect": "gold", "value": 18},
			{"label": "处理杂物（删去 1 张牌）", "effect": "remove_card"},
		],
	},
	{
		"id": "event_wanderer",
		"title": "迷途旅人",
		"description": "旅人请求你分享补给。",
		"options": [
			{"label": "给他 15 金币（回复 10 生命）", "effect": "heal_for_gold", "gold": 15, "heal": 10},
			{"label": "拒绝（获得 1 张牌）", "effect": "add_card"},
		],
	},
	{
		"id": "event_stone_tablet",
		"title": "石碑",
		"description": "石碑上写着关于体魄的古文。",
		"options": [
			{"label": "参悟（最大生命 +4）", "effect": "max_hp", "value": 4},
			{"label": "敲碎石碑（+20 金币）", "effect": "gold", "value": 20},
		],
	},
	{
		"id": "event_dark_contract",
		"title": "黑契约",
		"description": "空气中浮现一张正在燃烧的契约。",
		"options": [
			{"label": "签订（失去 10 生命，获得 2 张牌）", "effect": "cards_for_hp", "hp": 10, "count": 2},
			{"label": "撕毁（无事发生）", "effect": "none"},
		],
	},
]


static func get_templates() -> Array[Dictionary]:
	return TEMPLATES
