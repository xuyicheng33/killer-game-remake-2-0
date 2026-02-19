class_name RunRouteDispatcher
extends RefCounted

const ROUTE_MAP := "map"
const ROUTE_BATTLE := "battle"
const ROUTE_REWARD := "reward"
const ROUTE_REST := "rest"
const ROUTE_SHOP := "shop"
const ROUTE_EVENT := "event"
const ROUTE_GAME_OVER := "game_over"
const ROUTE_RUN_COMPLETE := "run_complete"


func route_for_map_node_type(node_type: MapNodeData.NodeType) -> String:
	match node_type:
		MapNodeData.NodeType.BATTLE, MapNodeData.NodeType.ELITE, MapNodeData.NodeType.BOSS:
			return ROUTE_BATTLE
		MapNodeData.NodeType.REST:
			return ROUTE_REST
		MapNodeData.NodeType.SHOP:
			return ROUTE_SHOP
		MapNodeData.NodeType.EVENT:
			return ROUTE_EVENT
		_:
			return ROUTE_MAP


func make_result(next_route: String, payload: Dictionary = {}) -> Dictionary:
	var out := {
		"next_route": next_route,
	}
	for key in payload.keys():
		out[key] = payload[key]
	return out
