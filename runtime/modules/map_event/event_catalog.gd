class_name EventCatalog
extends RefCounted

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
	{
		"id": "event_lucky_coin",
		"title": "幸运硬币",
		"description": "地上有一枚闪亮的硬币，正面朝上。",
		"options": [
			{"label": "捡起（+30 金币）", "effect": "gold", "value": 30},
			{"label": "无视（无事发生）", "effect": "none"},
		],
		"tags": ["rare"],
	},
	{
		"id": "event_mysterious_shrine",
		"title": "神秘祭坛",
		"description": "祭坛上燃烧着幽蓝色火焰。",
		"options": [
			{"label": "献祭生命（失去 6 生命，最大生命 +5）", "effect": "upgrade_for_hp", "hp": 6},
			{"label": "献祭金币（失去 25 金币，回复 15 生命）", "effect": "heal_for_gold", "gold": 25, "heal": 15},
		],
	},
	{
		"id": "event_card_trader",
		"title": "卡牌商人",
		"description": "一个神秘的商人愿意交换卡牌。",
		"options": [
			{"label": "删去 1 张牌，获得 30 金币", "effect": "remove_card"},
			{"label": "支付 30 金币，升级 1 张牌", "effect": "buy_card", "cost": 30},
		],
	},
	{
		"id": "event_healing_spring",
		"title": "治愈之泉",
		"description": "清澈的泉水散发着淡淡光芒。",
		"options": [
			{"label": "饮用（回复 20 生命）", "effect": "heal", "value": 20},
			{"label": "装瓶（获得 1 张牌）", "effect": "add_card"},
		],
		"tags": ["rare"],
	},
	{
		"id": "event_gambler",
		"title": "赌徒",
		"description": "一个赌徒向你发起挑战。",
		"options": [
			{"label": "赌 50 金币（50% 获得 100 金币，50% 失去 50 金币）", "effect": "gold", "value": 50},
			{"label": "拒绝（+5 金币）", "effect": "gold", "value": 5},
		],
	},
]


static func get_templates() -> Array[Dictionary]:
	return TEMPLATES
