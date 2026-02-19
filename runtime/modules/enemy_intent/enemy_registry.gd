class_name EnemyRegistry
extends RefCounted

const ENEMY_REGISTRY := {
	"crab": "res://content/enemies/crab/crab_enemy.tres",
	"bat": "res://content/enemies/bat/bat_enemy.tres",
}


static func get_enemy_stats(enemy_id: String) -> EnemyStats:
	var path: String = ENEMY_REGISTRY.get(enemy_id, "")
	if path.is_empty():
		push_warning("EnemyRegistry: unknown enemy_id '%s'" % enemy_id)
		return null
	
	if not ResourceLoader.exists(path):
		push_warning("EnemyRegistry: enemy resource not found at '%s'" % path)
		return null
	
	var stats_variant: Variant = load(path)
	if stats_variant is EnemyStats:
		return stats_variant
	return null


static func get_enemy_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in ENEMY_REGISTRY:
		ids.append(id)
	return ids
