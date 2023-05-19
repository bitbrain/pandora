class_name PandoraEntityBackend extends RefCounted

const UUID = preload("res://addons/pandora/utils/UUID.gd")


var _entities:Dictionary = {}
var _categories:Dictionary = {}
	
	
func create_entity(name:String) -> PandoraEntity:
	var entity = PandoraEntity.new()
	entity._id = UUID.generate()
	entity._name = name
	_entities[entity._id] = entity
	return entity
	
	
func create_category(name:String) -> PandoraCategory:
	var category = PandoraCategory.new()
	category._id = UUID.generate()
	category._name = name
	_categories[category._id] = category
	return category
	
	
func load_data(data:Dictionary) -> void:
	_entities = deserialize_entities(data["_entities"])
	_categories = deserialize_categories(data["_categories"])
	
	
func save_data() -> Dictionary:
	return {
		"_entities": serialize_data(_entities),
		"_categories": serialize_data(_categories),
	}
	
	
func deserialize_entities(data:Array[Dictionary]) -> Dictionary:
	var dict = {}
	for entity_data in data:
		var entity = PandoraEntity.new()
		entity.load_data(entity_data)
		dict[entity._id] = entity
	return dict
	
	
func deserialize_categories(data:Array[Dictionary]) -> Dictionary:
	var dict = {}
	for category_data in data:
		var category = PandoraCategory.new()
		category.load_data(category_data)
		dict[category._id] = category
	return dict


func serialize_data(data:Dictionary) -> Array[Dictionary]:
	var serialized_data:Array[Dictionary] = []
	for key in data:
		var entity = data[key] as PandoraEntity
		serialized_data.append(entity.save_data())
	return serialized_data
