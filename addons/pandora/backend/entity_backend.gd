class_name PandoraEntityBackend extends RefCounted

const id_generator = preload("res://addons/pandora/utils/id_generator.gd")


var _entities:Dictionary = {}
var _instances:Dictionary = {}
var _properties:Dictionary = {}
var _categories:Dictionary = {}
	
	
func create_entity(name:String, category:PandoraCategory) -> PandoraEntity:
	var entity = PandoraEntity.new(id_generator.generate(), name, "", category._id)
	_entities[entity._id] = entity
	category._children.append(entity)
	return entity
	
	
func create_entity_instance(of_entity:PandoraEntity) -> PandoraEntityInstance:
	var entity_instance = PandoraEntityInstance.new(id_generator.generate(), of_entity.get_entity_id(), _create_properties(of_entity.get_entity_properties()))
	_instances[entity_instance._id] = entity_instance
	return entity_instance


func create_category(name:String) -> PandoraCategory:
	var category = PandoraCategory.new(id_generator.generate(), name, "", "")
	_categories[category._id] = category
	return category
	
	
func create_property(on_category:PandoraCategory, name:String, default_value:Variant) -> PandoraProperty:
	var property = PandoraProperty.new(id_generator.generate(), name, PandoraProperty.type_of(default_value), default_value)
	_properties[property._id] = property
	on_category._properties.append(property)
	_invalidate_properties(on_category)
	return property
	
	
func get_entity(entity_id:String) -> PandoraEntity:
	if not _entities.has(entity_id):
		return null
	return _entities[entity_id]
	
	
func get_category(category_id:String) -> PandoraCategory:
	if not _categories.has(category_id):
		return null
	return _categories[category_id]
	
	
func load_data(data:Dictionary) -> void:
	_entities = deserialize_entities(data["_entities"])
	_categories = deserialize_categories(data["_categories"])
	_properties = deserialize_properties(data["_properties"])
	_instances = deserialize_instances(data["_instances"])
	for key in _entities:
		var entity = _entities[key] as PandoraEntity
		var category = _categories[entity._category_id] as PandoraCategory
		category._children.append(entity)
	
	
func save_data() -> Dictionary:
	return {
		"_entities": serialize_data(_entities),
		"_categories": serialize_data(_categories),
		"_instances": serialize_data(_instances),
		"_properties": serialize_data(_properties)
	}
	
	
func deserialize_entities(data:Array) -> Dictionary:
	var dict = {}
	for entity_data in data:
		var entity = PandoraEntity.new("", "", "", "")
		entity.load_data(entity_data)
		dict[entity._id] = entity
	return dict
	
	
func deserialize_categories(data:Array) -> Dictionary:
	var dict = {}
	for category_data in data:
		var category = PandoraCategory.new("", "", "", "")
		category.load_data(category_data)
		dict[category._id] = category
	return dict
	
	
func deserialize_instances(data:Array) -> Dictionary:
	var dict = {}
	for entity_data in data:
		var entity = PandoraEntityInstance.new("", "", [])
		entity.load_data(entity_data)
		dict[entity._id] = entity
	return dict
	
	
func deserialize_properties(data:Array) -> Dictionary:
	var dict = {}
	for property_data in data:
		var property = PandoraProperty.new("", "", "", "")
		property.load_data(property_data)
		dict[property._id] = property
	return dict


func serialize_data(data:Dictionary) -> Array[Dictionary]:
	var serialized_data:Array[Dictionary] = []
	for key in data:
		var entity = data[key] as PandoraEntity
		serialized_data.append(entity.save_data())
	return serialized_data
	

# used for testing only
func _clear() -> void:
	_entities.clear()
	_categories.clear()
	
	
func _create_properties(properties:Array[PandoraProperty]) -> Array[PandoraPropertyInstance]:
	var property_instances:Array[PandoraPropertyInstance] = []
	for property in properties:
		var id = id_generator.generate()
		var property_id = property.get_property_id()
		var default_value = property.get_default_value()
		property_instances.append(PandoraPropertyInstance.new(id, property_id, default_value))
	return property_instances
	
	
# recusively recalculates all the current properties for child entities of a given category
func _invalidate_properties(category:PandoraCategory) -> void:
	var property_references:Array[PandoraProperty] = []
	_append_properties(category, property_references)


func _append_properties(category:PandoraCategory, property_references:Array[PandoraProperty]) -> void:
	for property in category._properties:
		property_references.append(property)
	for child in category._children:
		if child is PandoraCategory:
			_append_properties(child as PandoraCategory, property_references)

