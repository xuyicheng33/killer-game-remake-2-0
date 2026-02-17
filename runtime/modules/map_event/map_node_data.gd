class_name MapNodeData
extends Resource

enum NodeType {
	BATTLE,
	ELITE,
	REST,
	SHOP,
	EVENT,
	BOSS
}

@export var id: String
@export var type: NodeType = NodeType.BATTLE
@export var title: String
@export_multiline var description: String
@export var reward_gold: int = 0
@export var floor_index: int = 0
@export var lane_index: int = 0
@export var next_node_ids: PackedStringArray = PackedStringArray()
