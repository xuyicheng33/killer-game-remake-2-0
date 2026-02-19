class_name CharacterRegistry
extends RefCounted

const CHARACTER_REGISTRY := {
	"warrior": "res://content/characters/warrior/warrior.tres",
	"mage": "res://content/characters/mage/mage.tres",
}

const DEFAULT_CHARACTER_ID := "warrior"


static func get_available_character_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in CHARACTER_REGISTRY.keys():
		ids.append(key as String)
	return ids


static func get_character_template(character_id: String) -> CharacterStats:
	var path: String = CHARACTER_REGISTRY.get(character_id, "")
	if path.is_empty():
		push_warning("Unknown character_id '%s', falling back to '%s'" % [character_id, DEFAULT_CHARACTER_ID])
		path = CHARACTER_REGISTRY.get(DEFAULT_CHARACTER_ID, "")
	
	if path.is_empty():
		push_error("CharacterRegistry: no valid character template found")
		return null
	
	if not ResourceLoader.exists(path):
		push_error("CharacterRegistry: template not found at '%s'" % path)
		return null
	
	var stats_variant: Variant = load(path)
	if stats_variant is CharacterStats:
		return stats_variant
	return null


static func get_selected_character_id() -> String:
	var env_id: String = OS.get_environment("SELECTED_CHARACTER_ID")
	if not env_id.is_empty():
		if CHARACTER_REGISTRY.has(env_id):
			return env_id
		push_warning("SELECTED_CHARACTER_ID '%s' not in registry, using default" % env_id)
	return DEFAULT_CHARACTER_ID


static func get_selected_character_template() -> CharacterStats:
	return get_character_template(get_selected_character_id())
