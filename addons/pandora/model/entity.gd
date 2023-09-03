## An entity acts a container for properties and is used to represent
## a category or an actual concept in any game.
@tool
class_name PandoraEntity extends Resource


const CATEGORY_ICON_PATH = "res://addons/pandora/icons/Folder.svg"


signal name_changed(new_name:String)
signal icon_changed(new_icon_path:String)
signal script_path_changed(new_script_path:String)
signal instance_script_path_changed(new_script_path:String)
signal generate_ids_changed(new_generate_ids:bool)
signal id_generation_class_changed(new_id_generation_path:String)


## used for export/import from scenes
@export var _id:String


var _name:String
var _icon_path:String
var _category_id:String
var _script_path:String
var _instance_script_path:String
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
var _ids_generation_class = ""


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
		
	
	func get_setting_override(name:String) -> Variant:
		return _property.get_setting_override(name)
		
		
	func get_setting(name:String) -> Variant:
		return _property.get_setting(name)
	
	
	func has_setting_override(name:String) -> bool:
		return _property.has_setting_override(name)
		
		
	func set_setting_override(name:String, override:Variant) -> void:
		_property.set_setting_override(name, override)
		
		
	func clear_setting_override(name:String) -> void:
		_property.clear_setting_override(name)


	func set_default_value(value: Variant) -> void:
		if not get_property_type().is_valid(value):
			print("Pandora error: value " + str(value) + " is incompatible with type ", get_property_type())
			return
		# ensure that a supported type is assigned.
		if value is PandoraEntity:
			value = PandoraReference.new(value.get_entity_id(), PandoraReference.Type.CATEGORY if value is PandoraCategory else PandoraReference.Type.ENTITY)
		_parent_entity._property_overrides[_property.get_property_name()] = value


	func get_default_value() -> Variant:
		if _parent_entity._property_overrides.has(_property.get_property_name()):
			var value = _parent_entity._property_overrides[_property.get_property_name()]
			if value is PandoraReference:
				return value.get_entity()
			return value
		return _property.get_default_value()


	func get_property_id() -> String:
		return _property.get_property_id()


	func get_property_name() -> String:
		return _property.get_property_name()


	func get_property_type() -> PandoraPropertyType:
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


## do not rely on _init as it breaks .tres files that may still
## point to a migrated PandoraEntity custom script.
func init_entity(id:String, name:String, icon_path:String, category_id:String) -> void:
	self._id = id
	self._name = name
	self._icon_path = icon_path
	self._category_id = category_id
	

## Creates an instance of this entity.
func instantiate() -> PandoraEntityInstance:
	var instance_properties = _create_instance_properties()
	return PandoraEntityInstance.new(get_entity_id(), instance_properties)

	
func get_entity_id() -> String:
	_initialize_if_not_loaded()
	return _id
	
	
func get_entity_name() -> String:
	_initialize_if_not_loaded()
	return tr(_name)
	
	
func get_icon_path() -> String:
	_initialize_if_not_loaded()
	if _icon_path != "":
		return _icon_path
	if get_category().get_icon_path() != CATEGORY_ICON_PATH:
		return get_category().get_icon_path()
	return "res://addons/pandora/icons/Object.svg"
	
	
func get_script_path() -> String:
	_initialize_if_not_loaded()
	if _script_path != "":
		return _script_path
	if _category_id != "" and get_category() != null:
		return get_category().get_script_path()
	return "res://addons/pandora/model/entity.gd"
	
	
func get_instance_script_path() -> String:
	_initialize_if_not_loaded()
	if _instance_script_path != "":
		return _instance_script_path
	if _category_id != "" and get_category() != null:
		return get_category().get_instance_script_path()
	return "res://addons/pandora/model/entity_instance.gd"


func set_entity_name(new_name:String) -> void:
	self._name = new_name
	name_changed.emit(new_name)
	
	
func set_icon_path(new_path:String) -> void:
	self._icon_path = new_path
	icon_changed.emit(new_path)


func set_script_path(new_path:String) -> void:
	self._script_path = new_path
	script_path_changed.emit(new_path)
	
	
func set_instance_script_path(new_path:String) -> void:
	self._instance_script_path = new_path
	instance_script_path_changed.emit(new_path)
	
	
func set_generate_ids(generate_ids:bool) -> void:
	self._generate_ids = generate_ids
	generate_ids_changed.emit(_generate_ids)


func is_generate_ids() -> bool:
	_initialize_if_not_loaded()
	if self._generate_ids:
		return _generate_ids
	if _category_id != "" and get_category() != null:
		return get_category().is_generate_ids()
	return false


func set_id_generation_class(id_generation_class:String) -> void:
	self._ids_generation_class = id_generation_class
	id_generation_class_changed.emit(id_generation_class)


func get_id_generation_class() -> String:
	_initialize_if_not_loaded()
	if _ids_generation_class != "":
		return _ids_generation_class
	if _category_id != "" and get_category() != null:
		return get_category().get_id_generation_class()
	return "EntityIds"

	
func get_category_id() -> String:
	_initialize_if_not_loaded()
	return _category_id


func get_entity_property(name:String) -> PandoraProperty:
	_initialize_if_not_loaded()
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
	
	
func get_string(property_name:String) -> String:
	if get_entity_property(property_name).get_default_value() == null:
		return ""
	if not has_entity_property(property_name):
		push_warning("unknown string property %s on instance %s" % [property_name, get_instance_id()])
		return ""
	if not get_entity_property(property_name).get_default_value() is String:
		push_error("property %s on instance %s is not a string" % [property_name, get_instance_id()])
		return ""
	return get_entity_property(property_name).get_default_value() as String
	
	
func get_integer(property_name:String) -> int:
	if not has_entity_property(property_name):
		push_warning("unknown integer property %s on instance %s" % [property_name, get_instance_id()])
		return 0
	# check if property is either int or float, as loading from json
	# auto-converts to float type
	var default_value = get_entity_property(property_name).get_default_value()
	if not default_value is int and not default_value is float:
		push_error("property %s on instance %s is not an int" % [property_name, get_instance_id()])
		return 0
	if default_value is float:
		return int(default_value)
	return default_value as int
	
	
func get_float(property_name:String) -> float:
	if get_entity_property(property_name).get_default_value() == null:
		return 0.0
	if not has_entity_property(property_name):
		push_warning("unknown float property %s on instance %s" % [property_name, get_instance_id()])
		return 0.0
	if not get_entity_property(property_name).get_default_value() is float:
		push_error("property %s on instance %s is not a float" % [property_name, get_instance_id()])
		return 0.0
	return get_entity_property(property_name).get_default_value() as float
	
	
func get_bool(property_name:String) -> bool:
	if get_entity_property(property_name).get_default_value() == null:
		return false
	if not has_entity_property(property_name):
		push_warning("unknown bool property %s on instance %s" % [property_name, get_instance_id()])
		return false
	if not get_entity_property(property_name).get_default_value() is bool:
		push_error("property %s on instance %s is not a bool" % [property_name, get_instance_id()])
		return false
	return get_entity_property(property_name).get_default_value() as bool
	
	
func get_color(property_name:String) -> Color:
	if get_entity_property(property_name).get_default_value() == null:
		return Color.WHITE
	if not has_entity_property(property_name):
		push_warning("unknown color property %s on instance %s" % [property_name, get_instance_id()])
		return Color.WHITE
	if not get_entity_property(property_name).get_default_value() is Color:
		push_error("property %s on instance %s is not a bool" % [property_name, get_instance_id()])
		return Color.WHITE
	return get_entity_property(property_name).get_default_value() as Color
	
	
func get_reference(property_name:String) -> PandoraEntity:
	if get_entity_property(property_name).get_default_value() == null:
		return null
	if not has_entity_property(property_name):
		push_warning("unknown reference property %s on instance %s" % [property_name, get_instance_id()])
		return null
	if not get_entity_property(property_name).get_default_value() is PandoraEntity:
		push_error("property %s on instance %s is not a reference" % [property_name, get_instance_id()])
		return null
	return get_entity_property(property_name).get_default_value() as PandoraEntity
	
	
func get_resource(property_name:String) -> Resource:
	if get_entity_property(property_name).get_default_value() == null:
		return null
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on instance %s" % [property_name, get_instance_id()])
		return null
	if not get_entity_property(property_name).get_default_value() is Resource:
		push_error("property %s on instance %s is not a resource" % [property_name, get_instance_id()])
		return null
	return get_entity_property(property_name).get_default_value() as Resource

	
func has_entity_property(name:String) -> bool:
	_initialize_if_not_loaded()
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
	_initialize_if_not_loaded()
	if _category_id == null or _category_id == "":
		return null
	return Pandora.get_category(_category_id)
	
	
func is_category(category_id:String) -> bool:
	if self._category_id == category_id:
		return true
	# find parent category with id
	var category = Pandora.get_category(self._category_id)
	var parent_id = category._category_id
	while parent_id != "":
		if parent_id == category_id:
			return true
		category = Pandora.get_category(parent_id)
		parent_id = category._category_id
	return false
	


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
	if data.has("_generate_ids"):
		_generate_ids = data["_generate_ids"]
	if data.has("_ids_generation_class"):
		_ids_generation_class = data["_ids_generation_class"]


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
	if _generate_ids:
		dict["_generate_ids"] = _generate_ids
	if _ids_generation_class != "":
		dict["_ids_generation_class"] = _ids_generation_class
	return dict


func _save_overrides() -> Dictionary:
	var output = {}
	for property_name in _property_overrides:
		var value = _property_overrides[property_name]
		var property = get_entity_property(property_name)
		var type = property.get_property_type()
		output[property_name] = {
			"type": type.get_type_name(),
			"value": type.write_value(value)
			}
	return output
	
	
func _load_overrides(data:Dictionary) -> Dictionary:
	var output = {}
	for property_name in data:
		var unparsed_data = data[property_name]
		var type = PandoraPropertyType.lookup(unparsed_data["type"])
		output[property_name] = type.parse_value(unparsed_data["value"])
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


func _to_string() -> String:
	return "<PandoraEntity '" + _name + "'>"


## FIXME: there is currently no signal for when resources
## are loaded via scenes. Therefore we have to load data
## lazily at runtime.
func _initialize_if_not_loaded() -> void:
	if _id == "":
		return
	
	if _name != "" or _category_id != "" or _script_path != "":
		# entity initialized already
		return
		
	var entity = Pandora.get_entity(_id) as PandoraEntity
	if entity == null:
		# entity got removed
		push_warning("Unable to initialize entity with id=" + _id + " from scene: got removed!")
		return
	
	init_entity(_id, entity._name, entity._icon_path, entity._category_id)
	
	## Be vary that PandoraEntity objects initialised from scene exports
	## are just a copy but with the same attributes. This is fine since
	## at runtime entities are read-only!
	self._properties = entity._properties
	self._property_map = entity._property_map
	self._inherited_properties = entity._inherited_properties
	self._property_overrides = entity._property_overrides
