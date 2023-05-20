class_name PandoraEntityBackend extends RefCounted

const id_generator = preload("res://addons/pandora/utils/id_generator.gd")


var _entities:Dictionary = {}
var _categories:Dictionary = {}
	
	
func create_entity(name:String, category:PandoraCategory) -> PandoraEntity:
	var entity = PandoraEntity.new()
	entity._id = id_generator.generate()
	entity._name = name
	entity._category_id = category._id
	_entities[entity._id] = entity
	category._children.append(entity)
	return entity
	
	
func create_category(name:String) -> PandoraCategory:
	var category = PandoraCategory.new()
	category._id = id_generator.generate()
	category._name = name
	_categories[category._id] = category
	return category
	
	
func load_data(data:Dictionary) -> void:
	_entities = deserialize_entities(data["_entities"])
	_categories = deserialize_categories(data["_categories"])
	for key in _entities:
		var entity = _entities[key] as PandoraEntity
		var category = _categories[entity._category_id] as PandoraCategory
		category._children.append(entity)
	
	
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
