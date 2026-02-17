class_name CardPile
extends Resource

signal card_pile_size_changed(cards_amount)

@export var cards: Array[Card] = []


func empty() -> bool:
	return cards.is_empty()


func draw_card() -> Card:
	if cards.is_empty():
		return null

	var card: Card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return card


func add_card(card: Card) -> void:
	if card == null:
		return
	cards.append(card)
	card_pile_size_changed.emit(cards.size())


func remove_card(card: Card) -> bool:
	var index := cards.find(card)
	if index == -1:
		return false

	cards.remove_at(index)
	card_pile_size_changed.emit(cards.size())
	return true


func size() -> int:
	return cards.size()


## 使用全局随机洗牌（非确定性，不推荐用于局内玩法）
func shuffle() -> void:
	cards.shuffle()


## 基于 RunRng 的确定性 Fisher-Yates 洗牌
## stream_key 用于区分不同场景的随机流，避免串流干扰
func shuffle_with_rng(stream_key: String) -> void:
	if cards.size() <= 1:
		return

	# Fisher-Yates 洗牌：从后往前遍历，随机交换
	for i in range(cards.size() - 1, 0, -1):
		var j: int = RunRng.randi_range(stream_key, 0, i)
		var tmp: Card = cards[i]
		cards[i] = cards[j]
		cards[j] = tmp


func clear() -> void:
	cards.clear()
	card_pile_size_changed.emit(cards.size())


func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s" % [i+1, cards[i].id])
	return "\n".join(_card_strings)
