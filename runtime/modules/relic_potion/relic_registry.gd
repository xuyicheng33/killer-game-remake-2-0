extends RefCounted

const DATA_DRIVEN_RELIC_SCRIPT := preload("res://runtime/modules/relic_potion/data_driven_relic.gd")

static var _factories: Dictionary = {}


static func register_factory(relic_id: String, factory: Callable) -> void:
	if relic_id.is_empty():
		return
	if not factory.is_valid():
		return
	_factories[relic_id] = factory


static func unregister_factory(relic_id: String) -> void:
	_factories.erase(relic_id)


static func clear_factories() -> void:
	_factories.clear()


static func create_relic(relic_data: RelicData) -> Object:
	if relic_data == null:
		return null

	var factory_variant: Variant = _factories.get(relic_data.id, null)
	if factory_variant is Callable:
		var created_variant: Variant = (factory_variant as Callable).call(relic_data)
		if created_variant != null and created_variant.has_method("handle_trigger"):
			return created_variant

	return DATA_DRIVEN_RELIC_SCRIPT.new(relic_data)
