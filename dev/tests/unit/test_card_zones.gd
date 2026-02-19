extends GutTest

const CARD_ZONES_MODEL_SCRIPT := preload("res://runtime/modules/card_system/card_zones_model.gd")

var _zones: CardZonesModel
var _stats: CharacterStats
var _hand: Hand


func before_all() -> void:
	gut.p("CardZones 测试套件初始化")


func before_each() -> void:
	_zones = CARD_ZONES_MODEL_SCRIPT.new()
	_stats = CharacterStats.new()
	_stats.draw_pile = CardPile.new()
	_stats.discard = CardPile.new()
	_stats.deck = CardPile.new()
	_hand = Hand.new()
	_zones.bind_context(_stats, _hand)


func after_each() -> void:
	if _zones != null:
		_zones.unbind_context()
	_zones = null
	if _hand != null and is_instance_valid(_hand):
		_hand.free()
	_hand = null
	_stats = null


func test_exhaust_card_with_upgrade_to_creates_upgraded_copy() -> void:
	var card := Card.new()
	card.id = "warrior_finisher_attack"
	card.cost = 2
	card.keyword_exhaust = true
	card.upgrade_to = "warrior_finisher_attack_plus"
	card.tooltip_text = "Exhaust. Upgrades on consume."
	_stats.discard.add_card(card)

	_zones._handle_post_card_played(card)

	assert_eq(_zones.get_exhaust_count(), 1, "原卡应进入消耗堆")
	assert_eq(_stats.discard.size(), 1, "弃牌堆应补入 1 张升级副本")
	var upgraded_variant: Variant = _stats.discard.cards[0]
	assert_true(upgraded_variant is Card, "升级副本类型应为 Card")
	if not (upgraded_variant is Card):
		return
	var upgraded := upgraded_variant as Card
	assert_eq(upgraded.id, "warrior_finisher_attack_plus", "升级副本 ID 应来自 upgrade_to")
	assert_eq(upgraded.cost, 1, "升级副本费用应 -1（最低 0）")
	assert_eq(upgraded.upgrade_to, "", "升级副本不应继续链式升级")


func test_exhaust_card_without_upgrade_to_only_moves_to_exhaust() -> void:
	var card := Card.new()
	card.id = "warrior_last_stand"
	card.cost = 1
	card.keyword_exhaust = true
	_stats.discard.add_card(card)

	_zones._handle_post_card_played(card)

	assert_eq(_zones.get_exhaust_count(), 1, "消耗牌应进入消耗堆")
	assert_eq(_stats.discard.size(), 0, "无 upgrade_to 时不应生成升级副本")
