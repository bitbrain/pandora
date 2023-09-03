## Manages entity, category and property definitions
## that usually ship with the game. Provides CRUD operations
## on entities as well as property inheritance and overriding.
class_name PandoraEntityBackend extends RefCounted


## Emitted when an entity (or category) gets created
signal entity_added(entity: PandoraEntity)


const PandoraEntityScript := preload("res://addons/pandora/model/entity.gd")


# entity id -> PandoraEntity
var _entities: Dictionary = {}
# property id -> PandoraProperty
var _properties: Dictionary = {}
# category id -> PandoraCategory
var _categories: Dictionary = {}
# list of categories on the root level
var _root_categories: Array[PandoraCategory] = []
# generates ids for new entities
var _id_generator: NanoIDGenerator


func _init(id_generator: NanoIDGenerator) -> void:
	self._id_generator = id_generator


## Creates a new category on an optional parent category
func create_category(name: String, parent_category: PandoraCategory = null) -> PandoraCategory:
	var category: PandoraCategory = PandoraCategory.new()
	category.init_entity(_id_generator.generate(), name, "", "")
	if parent_category != null:
		parent_category._children.append(category)
		category._category_id = parent_category._id
	else:
		# If category has no parent, it's a root category
		_root_categories.append(category)
	_categories[category._id] = category
	_propagate_properties(parent_category)
	entity_added.emit(category)
	return category


## Creates a new entity on the given PandoraCategory
func create_entity(name: String, category: PandoraCategory) -> PandoraEntity:
	var entity: PandoraEntity = _create_entity_from_script(
		category.get_script_path(),
		_id_generator.generate(),
		name,
		"",
		category._id
	)
	_entities[entity._id] = entity
	category._children.append(entity)
	_propagate_properties(category)
	entity_added.emit(entity)
	return entity


## Creates a new property on the given category parent
func create_property(on_category: PandoraCategory, name: String, type: String, default_value: Variant = null) -> PandoraProperty:
	if on_category.has_entity_property(name):
		push_error("Unable to create property " + name + " - property with the same name exists.")
		return null
	var property: PandoraProperty = PandoraProperty.new(_id_generator.generate(), name, type)
	property.set_default_value(default_value)
	property._category_id = on_category._id
	_properties[property._id] = property
	on_category._properties.append(property)
	_propagate_properties(on_category)
	return property


func regenerate_all_ids() -> void:
	for category in get_all_categories():
		regenerate_category_id(category)
	for entity in get_all_entities():
		regenerate_entity_id(entity)
	for property in get_all_properties():
		regenerate_property_id(property)


func regenerate_category_id(category: PandoraCategory) -> void:
	var new_id := _id_generator.generate()
	_categories.erase(category._id)
	for child in category._children:
		child._category_id = new_id
	for key in _properties:
		if _properties[key]._category_id == category._id:
			_properties[key]._category_id = new_id
	category._id = new_id
	_categories[category._id] = category


func regenerate_entity_id(entity: PandoraEntity) -> void:
	_entities.erase(entity._id)
	entity._id = _id_generator.generate()
	_entities[entity._id] = entity


func regenerate_property_id(property: PandoraProperty) -> void:
	_properties.erase(property._id)
	property._id = _id_generator.generate()
	_properties[property._id] = property


## Returns an existing category or null otherwise
func get_category(category_id: String) -> PandoraCategory:
	if not _categories.has(category_id):
		return null
	return _categories[category_id]


## Returns an existing entity (or category) or null otherwise
func get_entity(entity_id: String) -> PandoraEntity:
	if _categories.has(entity_id):
		return get_category(entity_id)
	if not _entities.has(entity_id):
		return null
	return _entities[entity_id]


## Returns an existing property or null otherwise
func get_property(property_id: String) -> PandoraProperty:
	if not _properties.has(property_id):
		return null
	return _properties[property_id]


## Returns a list of all root categories
func get_all_roots() -> Array[PandoraCategory]:
	return _root_categories


## Returns a list of all categories
func get_all_categories(parent: PandoraCategory = null, sort: Callable = func(a, b): return false) -> Array[PandoraEntity]:
	var categories: Array[PandoraEntity] = []
	if parent:
		_collect_categories_recursive(parent, categories)
	else:
		for key in _categories:
			categories.append(_categories[key])
	categories.sort_custom(sort)
	return categories


func get_all_entities(parent: PandoraCategory = null, sort: Callable = func(a, b): return false) -> Array[PandoraEntity]:
	var entities: Array[PandoraEntity] = []
	if parent:
		_collect_entities_recursive(parent, entities)
	else:
		for key in _entities:
			entities.append(_entities[key])
	entities.sort_custom(sort)
	return entities


func get_all_properties(parent: PandoraCategory = null, sort: Callable = func(a, b): return false) -> Array[PandoraProperty]:
	var properties: Array[PandoraProperty] = []
	if parent:
		properties.append_array(parent._properties)
	else:
		for key in _properties:
			properties.append(_properties[key])
	properties.sort_custom(sort)
	return properties


## Deletes an existing category and all of its children
## recursively.
func delete_category(category: PandoraCategory) -> void:
	for child in category._children:
		if child is PandoraCategory:
			delete_category(child as PandoraCategory)
		else:
			# do not use delete_entity here as we do not want
			# to modify the list of children that we are currently
			# iterating through!
			child._property_map.clear()
			child._inherited_properties.clear()
			_entities.erase(child._id)
	category._children.clear()
	category._property_map.clear()
	category._inherited_properties.clear()
	for property in category._properties:
		_properties.erase(property._id)
	category._properties.clear()
	_categories.erase(category._id)
	if _root_categories.has(category):
		_root_categories.erase(category)


## Deletes an entity (or category)
func delete_entity(entity: PandoraEntity) -> void:
	if entity is PandoraCategory:
		delete_category(entity as PandoraCategory)
		return
	var parent_category := get_category(entity._category_id)
	parent_category._children.erase(entity)
	entity._property_map.clear()
	entity._inherited_properties.clear()
	_entities.erase(entity._id)


## Deletes a property from a parent category
func delete_property(property: PandoraProperty) -> void:
	var parent_category := get_category(property._category_id)
	parent_category._delete_property(property.get_property_name())
	_properties.erase(property._id)
	_propagate_properties(parent_category)


## Returns a dictionary that can be used for further storage.
## Call the load_data(data) method to re-initialize a backend.
func save_data() -> Dictionary:
	return {
		"_entities": _serialize_data(_entities),
		"_categories": _serialize_data(_categories),
		"_properties": _serialize_data(_properties)
	}


## Initialize this backend with the given data dictionary.
## The data needs to come from a source that was produced via
## the save_data() method.
func load_data(data: Dictionary) -> void:
	_root_categories.clear()
	_categories = _deserialize_categories(data["_categories"])
	_entities = _deserialize_entities(data["_entities"])
	_properties = _deserialize_properties(data["_properties"])
	for key in _categories:
		var category: PandoraCategory = _categories[key]
		if category._category_id:
			if not _categories.has(category._category_id):
				push_error("Pandora error: category " + category._category_id + " on category does not exist")
				continue
			var parent: PandoraCategory = _categories[category._category_id]
			parent._children.append(category)
	for key in _entities:
		var entity: PandoraEntity = _entities[key]
		if not _categories.has(entity._category_id):
			push_error("Pandora error: category " + entity._category_id + " on entity does not exist")
			continue
		var category: PandoraCategory = _categories[entity._category_id]
		category._children.append(entity)
	for key in _properties:
		var property: PandoraProperty = _properties[key]
		if not _categories.has(property._category_id):
			push_error("Pandora error: category " + property._category_id + " on property does not exist")
			continue
		var category: PandoraCategory = _categories[property._category_id]
		category._properties.append(property)

	# propagate properties from roots
	for root_category in _root_categories:
		_propagate_properties(root_category)


func _serialize_data(data: Dictionary) -> Array[Dictionary]:
	var serialized_data: Array[Dictionary] = []
	for key in data:
		serialized_data.append(data[key].save_data())
	return serialized_data


func _deserialize_categories(data: Array) -> Dictionary:
	var dict: Dictionary = {}
	for category_data in data:
		var category := PandoraCategory.new()
		category.load_data(category_data)
		dict[category._id] = category
		if category._category_id == "":
			# If category has no parent, it's a root category
			_root_categories.append(category)
	return dict


func _deserialize_entities(data: Array) -> Dictionary:
	var dict: Dictionary = {}
	for entity_data in data:
		# only when entity has an overridden class, initialise it.
		# otherwise rely on the script path of the parent category.
		if entity_data.has("_script_path"):
			var entity := _create_entity_from_script(entity_data["_script_path"], "", "", "", "")
			entity.load_data(entity_data)
			dict[entity._id] = entity
		else:
			var parent_category: PandoraCategory = _categories[entity_data["_category_id"]]
			var entity := _create_entity_from_script(parent_category.get_script_path(), "", "", "", "")
			entity.load_data(entity_data)
			dict[entity._id] = entity
	return dict


func _deserialize_properties(data: Array) -> Dictionary:
	var dict: Dictionary = {}
	for property_data in data:
		var property := PandoraProperty.new("", "", "")
		property.load_data(property_data)
		dict[property._id] = property
	return dict


func _create_entity_from_script(path: String, id: String, name: String, icon_path: String, category_id: String) -> PandoraEntity:
	var clazz := _get_entity_class(path)
	var new_method := _find_first_method_of_script(clazz, "init_entity")
	if not new_method.has("args"):
		push_error("ERROR - Pandora is unable to correctly resolve new() method.")
		var entity := PandoraEntityScript.new()
		entity.init_entity(id, name, icon_path, category_id)
		return entity
	var expected_method := _find_first_method_of_script(PandoraEntityScript, "init_entity")
	if new_method["args"].size() != expected_method["args"].size():
		push_warning("init_entity() method has incorrect signature! Requires " + str(expected_method["args"].size()) + " arguments - defaulting to PandoraEntity instead.")
		var entity := PandoraEntityScript.new()
		entity.init_entity(id, name, icon_path, category_id)
		return entity

	var entity := clazz.new()
	if not entity is PandoraEntity:
		push_warning("Script '" + path + "' must extend PandoraEntity - defaulting to PandoraEntity instead.")
		entity = PandoraEntityScript.new()

	entity.init_entity(id, name, icon_path, category_id)
	return entity


## searches for the first occurence of the method.
## methods can occur multiple times in the order of inheritance.
func _find_first_method_of_script(script: GDScript, method_name: String) -> Dictionary:
	for method in script.get_script_method_list():
		if method.name == method_name:
			return method
	return {}


## recusively propagate properties into children
func _propagate_properties(category: PandoraCategory) -> void:
	if category == null:
		return
	for child in category._children:
		for property in category.get_entity_properties():
			# only propagate if not already existing!
			# e.g. it could have an override already in place
			if not child.has_entity_property(property.get_property_name()):
				child._properties.append(property)
		if child is PandoraCategory:
			_propagate_properties(child)


func _collect_categories_recursive(category: PandoraCategory, list: Array[PandoraEntity]) -> void:
	for child in category._children:
		if child is PandoraCategory:
			list.append(child)
			_collect_categories_recursive(child, list)


func _collect_entities_recursive(category: PandoraCategory, list: Array[PandoraEntity]) -> void:
	for child in category._children:
		if child is PandoraEntity and not (child is PandoraCategory):
			list.append(child)
		elif child is PandoraCategory:
			_collect_entities_recursive(child, list)


func _get_entity_class(path: String) -> GDScript:
	var EntityClass := load(path)
	if EntityClass == null or not EntityClass.has_source_code():
		push_warning("Unable to find " + path + " - defaulting to PandoraEntity instead.")
		EntityClass = PandoraEntityScript
	return EntityClass


# used for testing only
func _clear() -> void:
	_entities.clear()
	_categories.clear()
	_properties.clear()
	_root_categories.clear()
