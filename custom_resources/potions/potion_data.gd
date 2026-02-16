class_name PotionData
extends Resource

enum EffectType {
	HEAL,
	GOLD,
	BLOCK,
}

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var effect_type: EffectType = EffectType.HEAL
@export var value: int = 0

