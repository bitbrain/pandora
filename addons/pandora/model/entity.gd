## An entity acts a container for properties and is used to represent
## a category or an actual concept in any game.
class_name PandoraEntity extends Resource


signal name_changed(new_name:String)
signal icon_changed(new_icon_path:String)
signal script_path_changed(new_script_path:String)


## Wrapper around PandoraProperty that is used to manage overrides.
## This is required to wrap existing properties that were inherited
## from parents to ensure that a value can be overriden. At the same
## time, changing the parent property should automatically work independently
## of this implementation.
class OverridingProperty extends PandoraProperty:
	
	
	var _property: PandoraProperty
	var _parent_entity: PandoraEntity


	func _init(parent_entity: PandoraEntity, property: PandoraProperty) -> void:
		self._property = property
		self._parent_entity = parent_entity
		self._property.name_changed.connect(_change_name)


	func set_default_value(value: Variant) -> void:
		_parent_entity._property_overrides[_property.get_property_name()] = value


	func get_default_value() -> Variant:
		if _parent_entity._property_overrides.has(_property.get_property_name()):
			return _parent_entity._property_overrides[_property.get_property_name()]
		return _property.get_default_value()


	func get_property_id() -> String:
		return _property.get_property_id()


	func get_property_name() -> String:
		return _property.get_property_name()


	func get_property_type() -> String:
		return _property.get_property_type()
		
	
	func get_category_id() -> String:
		if _parent_entity is PandoraCategory:
			return _parent_entity._id
		else:
			return _property.get_category_id()
			
	
	func get_original_category_id() -> String:
		return _property.get_original_category_id()


	func is_original() -> bool:
		return _property.get_category_id() == _parent_entity._id
		
		
	func is_overridden() -> bool:
		var override_exists = _parent_entity._property_overrides.has(_property.get_property_name())
		return override_exists and _parent_entity._property_overrides[get_property_name()] != _property.get_default_value()
		
		
	func reset_to_default() -> void:
		var had_override = _parent_entity._property_overrides.has(_property.get_property_name())
		if had_override:
			_parent_entity._property_overrides.erase(_property.get_property_name())
		
		
	
	func _change_name(old_name:String, new_name:String) -> void:
		if _parent_entity._property_overrides.has(old_name):
			var value = _parent_entity._property_overrides[old_name]
			_parent_entity._property_overrides.erase(old_name)
			_parent_entity._property_overrides[new_name] = value
		if _parent_entity._property_map.has(old_name):
			var old_property = _parent_entity._property_map[old_name]
			_parent_entity._property_map.erase(old_name)
			_parent_entity._property_map[new_name] = old_property
		var old_inherited_property = _parent_entity._inherited_properties[old_name]
		_parent_entity._inherited_properties.erase(old_name)
		_parent_entity._inherited_properties[new_name] = old_inherited_property
		


var _id:String
var _name:String
var _icon_path:String
var _category_id:String
var _script_path:String
# not persisted but computed at runtime
var _properties:Array[PandoraProperty] = []
# property name -> Property
var _property_map = {}
# property name -> InheritedProperty (cache)
var _inherited_properties = {}
var _property_overrides = {}

# there is the option to generate child entity
# ids + category ids into a file for easier access.
var _generate_ids = false 
var _ids_generation_path = ""


func _init(id:String, name:String, icon_path:String, category_id:String) -> void:
	self._id = id
	self._name = name
	self._icon_path = icon_path
	self._category_id = category_id
	

## Creates an instance of this entity.
func instantiate() -> PandoraEntityInstance:
	var instance_properties = _create_instance_properties()
	return PandoraEntityInstance.new(get_entity_id(), instance_properties)

	
func get_entity_id() -> String:
	return _id
	
	
func get_entity_name() -> String:
	return tr(_name)
	
	
func get_icon_path() -> String:
	if _icon_path != "":
		return _icon_path
	return "res://addons/pandora/icons/Object.svg"
	
	
func get_script_path() -> String:
	if _script_path != "":
		return _script_path
	if _category_id != "" and get_category()._script_path != "":
		return get_category()._script_path
	return "res://addons/pandora/model/entity.gd"


func set_entity_name(new_name:String) -> void:
	self._name = new_name
	name_changed.emit(new_name)
	
	
func set_icon_path(new_path:String) -> void:
	self._icon_path = new_path
	icon_changed.emit(new_path)
	
	
func set_script_path(new_path:String) -> void:
	self._script_path = new_path
	script_path_changed.emit(new_path)
	
	
func get_category_id() -> String:
	return _category_id


func get_entity_property(name:String) -> PandoraProperty:
	if _property_map.has(name):
		var property = _property_map[name] as PandoraProperty
		if property.get_category_id() != _id:
			if not _inherited_properties.has(name):
				_inherited_properties[name] = OverridingProperty.new(self, property)
			return _inherited_properties[name]
		return property
	else:
		for property in get_entity_properties():
			if property.get_property_name() == name:
				if not _property_map.has(name):
					_property_map[name] = property
				return property
	return null

	
func has_entity_property(name:String) -> bool:
	return get_entity_property(name) != null
	

func get_entity_properties() -> Array[PandoraProperty]:
	var properties:Array[PandoraProperty] = []
	for property in _properties:
		if property.get_category_id() != _id:
			if not _inherited_properties.has(property.get_property_name()):
				_inherited_properties[property.get_property_name()] = OverridingProperty.new(self, property)
			properties.append(_inherited_properties[property.get_property_name()])
		else:
			properties.append(property)
	return properties
	
	
func get_category() -> PandoraCategory:
	if _category_id == null or _category_id == "":
		return null
	return Pandora.get_category(_category_id)


## Initializes this entity with the given data dictionary.
## Dictionary needs to confirm the structure of this entity.
func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_category_id = data["_category_id"]
	if data.has("_icon_path"):
		_icon_path = data["_icon_path"]
	if data.has("_property_overrides"):
		_property_overrides = _load_overrides(data["_property_overrides"])
	if data.has("_script_path"):
		_script_path = data["_script_path"]


## Produces a data dictionary that can be used on load_data()
func save_data() -> Dictionary:
	var dict = {
		"_id": _id,
		"_name": _name,
		"_category_id": _category_id
	}
	if _icon_path != "":
		dict["_icon_path"] = _icon_path
	if not _property_overrides.is_empty():
		dict["_property_overrides"] = _save_overrides()
	if _script_path != "":
		dict["_script_path"] = _script_path
	return dict


func _save_overrides() -> Dictionary:
	var output = {}
	for property_name in _property_overrides:
		var value = _property_overrides[property_name]
		var property = get_entity_property(property_name)
		output[property_name] = {
			"type": property.get_property_type(),
			"value": PandoraProperty.write_value(value)
			}
	return output
	
	
func _load_overrides(data:Dictionary) -> Dictionary:
	var output = {}
	for property_name in data:
		var unparsed_data = data[property_name]
		output[property_name] = PandoraProperty.parse_value(unparsed_data["value"], unparsed_data["type"])
	return output


func _delete_property(name:String) -> void:
	if _property_map.has(name):
		_property_map.erase(name)
	_inherited_properties.erase(name)
	_property_overrides.erase(name)
	var original_property:PandoraProperty
	for property in _properties:
		if property.get_property_name() == name:
			original_property = property
	_properties.erase(original_property)


## Generates instanced properties from an existing entity.
## A property that is instanced can be change its value independently
## of the original property.
func _create_instance_properties() -> Array[PandoraPropertyInstance]:
	var property_instances:Array[PandoraPropertyInstance] = []
	for property in get_entity_properties():
		var property_id = property.get_property_id()
		var default_value = property.get_default_value()
		property_instances.append(PandoraPropertyInstance.new(property, default_value))
	return property_instances
