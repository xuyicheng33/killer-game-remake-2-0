class_name RunFlowContext
extends RefCounted


var pending_reward_gold: int = 0
var pending_node_type: MapNodeData.NodeType = MapNodeData.NodeType.BATTLE


func reset() -> void:
	pending_reward_gold = 0
	pending_node_type = MapNodeData.NodeType.BATTLE


func apply_map_node_result(command_result: Dictionary, fallback_node_type: MapNodeData.NodeType) -> void:
	pending_node_type = _coerce_node_type(int(command_result.get("node_type", int(fallback_node_type))))
	pending_reward_gold = int(command_result.get("reward_gold", pending_reward_gold))


func apply_route_result(command_result: Dictionary) -> void:
	var next_route := str(command_result.get("next_route", RunRouteDispatcher.ROUTE_MAP))
	if next_route == RunRouteDispatcher.ROUTE_BATTLE:
		pending_reward_gold = int(command_result.get("reward_gold", pending_reward_gold))


func reward_gold_for(command_result: Dictionary) -> int:
	return int(command_result.get("reward_gold", pending_reward_gold))


static func _coerce_node_type(raw_value: int) -> MapNodeData.NodeType:
	match raw_value:
		int(MapNodeData.NodeType.BATTLE):
			return MapNodeData.NodeType.BATTLE
		int(MapNodeData.NodeType.ELITE):
			return MapNodeData.NodeType.ELITE
		int(MapNodeData.NodeType.REST):
			return MapNodeData.NodeType.REST
		int(MapNodeData.NodeType.SHOP):
			return MapNodeData.NodeType.SHOP
		int(MapNodeData.NodeType.EVENT):
			return MapNodeData.NodeType.EVENT
		int(MapNodeData.NodeType.BOSS):
			return MapNodeData.NodeType.BOSS
		_:
			return MapNodeData.NodeType.BATTLE
