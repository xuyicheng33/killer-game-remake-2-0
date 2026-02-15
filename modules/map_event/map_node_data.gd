class_name MapNodeData
extends Resource

enum NodeType {
	BATTLE,
	ELITE,
	REST,
	SHOP,
	EVENT
}

@export var id: String
@export var type: NodeType = NodeType.BATTLE
@export var title: String
@export_multiline var description: String
@export var reward_gold: int = 0

