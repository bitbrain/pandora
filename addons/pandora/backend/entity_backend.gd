class_name PandoraEntityBackend extends RefCounted

const id_generator = preload("res://addons/pandora/utils/id_generator.gd")


var _entities:Dictionary = {}
var _properties:Dictionary = {}
var _categories:Dictionary = {}
	
	
func create_entity(name:String, category:PandoraCategory) -> PandoraEntity:
	var entity = PandoraEntity.new(id_generator.generate(), name, "", category._id)
	_entities[entity._id] = entity
	category._children.append(entity)
	_invalidate_properties(category)
	return entity


func create_category(name:String, parent_category:PandoraCategory = null) -> PandoraCategory:
	var category = PandoraCategory.new(id_generator.generate(), name, "", "")
	if parent_category != null:
		parent_category._children.append(category)
		category._category_id = parent_category._id
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
	
	
func get_property(property_id:String) -> PandoraProperty:
	if not _properties.has(property_id):
		return null
	return _properties[property_id]
	
	
func load_data(data:Dictionary) -> void:
	_entities = deserialize_entities(data["_entities"])
	_categories = deserialize_categories(data["_categories"])
	_properties = deserialize_properties(data["_properties"])
	for key in _entities:
		var entity = _entities[key] as PandoraEntity
		var category = _categories[entity._category_id] as PandoraCategory
		category._children.append(entity)
	
	
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
	_properties.clear()
	
	
func _find_root_category(category:PandoraCategory) -> PandoraCategory:
	if category._category_id == "":
		# this category has no parent- it is the root!
		return category
	var parent_category_id:String = category._category_id
	while true:
		var parent_category = get_category(parent_category_id)
		if parent_category._category_id == "":
			return parent_category
		parent_category_id = parent_category._category_id
	return null

	
# recusively recalculates all the current properties for child entities of a given category
func _invalidate_properties(category:PandoraCategory) -> void:
	var property_references:Array[PandoraProperty] = []
	# FIXME we currently have to start from the root category as we
	# currently do not cache the parent properties on children except
	# entities themselves.
	var root_category = _find_root_category(category)
	_append_properties(root_category, property_references)


func _append_properties(category:PandoraCategory, property_references:Array[PandoraProperty]) -> void:
	for property in category._properties:
		property_references.append(property)
	var child_categories:Array[PandoraCategory] = []
	for child in category._children:
		if child is PandoraCategory:
			child_categories.append(child as PandoraCategory)
		else:
			# child is just a plain entity -> set properties
			child._properties.clear()
			for property in property_references:
				child._properties.append(property)
	for child in child_categories:
		_append_properties(child, property_references)

