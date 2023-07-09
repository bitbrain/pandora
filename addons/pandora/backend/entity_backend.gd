class_name PandoraEntityBackend extends RefCounted

signal entity_added(entity:PandoraEntity)


const id_generator = preload("res://addons/pandora/utils/id_generator.gd")


var _entities:Dictionary = {}
var _properties:Dictionary = {}
var _categories:Dictionary = {}
var _root_categories:Array[PandoraEntity] = []
	
	
func create_entity(name:String, category:PandoraCategory) -> PandoraEntity:
	var entity = PandoraEntity.new(id_generator.generate(), name, "", category._id)
	_entities[entity._id] = entity
	category._children.append(entity)
	_propagate_properties(category)
	entity_added.emit(entity)
	return entity


func create_category(name:String, parent_category:PandoraCategory = null) -> PandoraCategory:
	var category = PandoraCategory.new(id_generator.generate(), name, "", "")
	if parent_category != null:
		parent_category._children.append(category)
		category._category_id = parent_category._id
	else:
		# If category has no parent, it's a root category
		_root_categories.append(category)
	_categories[category._id] = category
	_propagate_properties(category)
	entity_added.emit(category)
	return category
	
	
func create_property(on_category:PandoraCategory, name:String, type:String, defaultValue:Variant = null) -> PandoraProperty:
	if on_category.has_entity_property(name):
		push_error("Unable to create property " + name + " - property with the same name exists.")
		return null
	var property = PandoraProperty.new(id_generator.generate(), name, type, defaultValue if defaultValue else PandoraProperty.default_value_of(type))
	property._category_id = on_category._id
	_properties[property._id] = property
	on_category._properties.append(property)
	_propagate_properties(on_category)
	return property
	
	
func get_entity(entity_id:String) -> PandoraEntity:
	if not _entities.has(entity_id):
		return null
	return _entities[entity_id]
	
	
func get_category(category_id:String) -> PandoraCategory:
	if not _categories.has(category_id):
		return null
	return _categories[category_id]
	
	
func get_property(property_id:String) -> PandoraProperty:
	if not _properties.has(property_id):
		return null
	return _properties[property_id]
	
	
func get_all_categories() -> Array[PandoraEntity]:
	return _root_categories
	
	
func get_all_entities() -> Array[PandoraEntity]:
	var entities:Array[PandoraEntity] = []
	for key in _entities:
		entities.append(_entities[key])
	entities.sort_custom(_compare_entities)
	return entities
	
	
func load_data(data:Dictionary) -> void:
	_root_categories.clear()
	_entities = deserialize_entities(data["_entities"])
	_categories = deserialize_categories(data["_categories"])
	_properties = deserialize_properties(data["_properties"])
	for key in _categories:
		var category = _categories[key] as PandoraCategory
		if category._category_id:
			var parent = _categories[category._category_id] as PandoraCategory
			parent._children.append(category)
	for key in _entities:
		var entity = _entities[key] as PandoraEntity
		var category = _categories[entity._category_id] as PandoraCategory
		category._children.append(entity)
	for key in _properties:
		var property = _properties[key] as PandoraProperty
		var category = _categories[property._category_id] as PandoraCategory
		category._properties.append(property)
		
	# propagate properties from roots
	for root_category in _root_categories:
		_propagate_properties(root_category)
	
func save_data() -> Dictionary:
	return {
		"_entities": serialize_data(_entities),
		"_categories": serialize_data(_categories),
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
		if category._category_id == "":
			# If category has no parent, it's a root category
			_root_categories.append(category)
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
		serialized_data.append(data[key].save_data())
	return serialized_data
	

# used for testing only
func _clear() -> void:
	_entities.clear()
	_categories.clear()
	_properties.clear()
	_root_categories.clear()

	
## recusively propagate properties into children
func _propagate_properties(category:PandoraCategory) -> void:
	for child in category._children:
		for property in child.get_entity_properties():
			if property._category_id != child._id and not category.has_entity_property(property.get_property_name()):
				# property is inherited but does not seem to exist any longer!
				# -> clear it out!
				if property._default_value_overrides.has(child._id):
					property._default_value_overrides.erase(child._id)
				if child._property_map.has(property._id):
					child._property_map.erase(property._id)
				child.get_entity_properties().erase(property)
		for property in category.get_entity_properties():
			# only propagate if not already existing!
			# e.g. it could have an override already in place
			if not child.has_entity_property(property.get_property_name()):
				child._properties.append(property)
		if child is PandoraCategory:
			_propagate_properties(child)


func _compare_entities(entity1:PandoraEntity, entity2:PandoraEntity) -> bool:
	return entity1.get_entity_name() < entity2.get_entity_name()
