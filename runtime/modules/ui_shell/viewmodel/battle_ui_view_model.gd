class_name BattleUIViewModel
extends RefCounted


func project_zone_counts(draw_count: int, hand_count: int, discard_count: int, exhaust_count: int) -> Dictionary:
	return {
		"draw_count": draw_count,
		"hand_count": hand_count,
		"discard_count": discard_count,
		"exhaust_count": exhaust_count,
		"zone_counts_text": "抽牌堆：%d  手牌：%d\n弃牌堆：%d  消耗堆：%d" % [
			draw_count,
			hand_count,
			discard_count,
			exhaust_count,
		],
	}
