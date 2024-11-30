## An entity acts a container for properties and is used to represent
## a category or an actual concept in any game.
@tool
class_name PandoraEntity extends Resource

const ScriptUtil = preload("res://addons/pandora/util/script_util.gd")
const NanoIdGenerator = preload("res://addons/pandora/util/nanoid_generator.gd")
const CATEGORY_ICON_PATH = "res://addons/pandora/icons/Folder.svg"
const ENTITY_ICON_PATH = "res://addons/pandora/icons/Object.svg"

# we require nano ids for instances as they are non-incremental
# and instances are persisted outside of Pandora.
static var _INSTANCE_ID_GENERATOR = NanoIdGenerator.new()

signal name_changed(new_name: String)
signal order_changed(new_index: int)
signal icon_changed(new_icon_path: String)
signal icon_color_changed(new_icon_color: Color)
signal script_path_changed(new_script_path: String)
signal instance_script_path_changed(new_script_path: String)
signal generate_ids_changed(new_generate_ids: bool)
signal id_generation_class_changed(new_id_generation_path: String)

## used for export/import from scenes
@export var _id: String

var _name: String
var _icon_path: String
var _category_id: String:
	get():
		if is_instance():
			var original = Pandora.get_entity(_id)
			if original:
				return original._category_id
			else:
				return ''
		else:
			return _category_id
var _script_path: String
var _icon_color: Color = Color.TRANSPARENT
var _index: int
# not persisted but computed at runtime
var _properties: Array[PandoraProperty] = []
# property name -> Property
var _property_map = {}
# property name -> InheritedProperty (cache)
var _inherited_properties = {}
var _property_overrides = {}
# there is the option to generate child entity
# ids + category ids into a file for easier access.
var _generate_ids = false
var _ids_generation_class = ""

# String -> PandoraPropertyInstance
var _instance_properties: Dictionary = {}
var _instance_id: String


## Wrapper around PandoraProperty that is used to manage overrides.
## This is required to wrap existing properties that were inherited
## from parents to ensure that a value can be overriden. At the same
## time, changing the parent property should automatically work independently
## of this implementation.
class OverridingProperty:
	extends PandoraProperty

	var _property: PandoraProperty
	var _parent_entity: PandoraEntity

	func _init(parent_entity: PandoraEntity, property: PandoraProperty) -> void:
		self._property = property
		self._parent_entity = parent_entity
		self._property.name_changed.connect(_change_name)

	func get_setting_override(name: String) -> Variant:
		return _property.get_setting_override(name)

	func get_setting(name: String) -> Variant:
		return _property.get_setting(name)

	func has_setting_override(name: String) -> bool:
		return _property.has_setting_override(name)

	func set_setting_override(name: String, override: Variant) -> void:
		_property.set_setting_override(name, override)

	func clear_setting_override(name: String) -> void:
		_property.clear_setting_override(name)

	func set_default_value(value: Variant) -> void:
		if not get_property_type().is_valid(value):
			print(
				"Pandora error: value " + str(value) + " is incompatible with type ",
				get_property_type()
			)
			return
		# ensure that a supported type is assigned.
		if value is PandoraEntity:
			value = PandoraReference.new(
				value.get_entity_id(),
				(
					PandoraReference.Type.CATEGORY
					if value is PandoraCategory
					else PandoraReference.Type.ENTITY
				)
			)
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
		return (
			override_exists
			and (
				_parent_entity._property_overrides[get_property_name()]
				!= _property.get_default_value()
			)
		)

	func reset_to_default() -> void:
		var had_override = _parent_entity._property_overrides.has(_property.get_property_name())
		if had_override:
			_parent_entity._property_overrides.erase(_property.get_property_name())

	func _change_name(old_name: String, new_name: String) -> void:
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
func init_entity(id: String, name: String, icon_path: String, category_id: String) -> void:
	self._id = id
	self._name = name
	self._icon_path = icon_path
	self._category_id = category_id


## Similar to instantiate(), this method will duplicate an existing
## instance with all its properties.
## In case this is called on an entity, it will act as instantiate()
func duplicate_instance() -> PandoraEntity:
	var new_instance = instantiate()
	# ensure to carry over any overrides!
	if is_instance():
		for key in _instance_properties:
			var duplicated_property = _instance_properties[key].duplicate_instance()
			new_instance._instance_properties[key] = duplicated_property
	return new_instance


## Creates an instance of this entity.
func instantiate() -> PandoraEntity:
	var entity = ScriptUtil.create_entity_from_script(get_script_path(), "", "", "", "")
	if entity != null:
		# ensure to store the id on instances too, so scene saving does not break.
		entity._id = get_entity_id()
		entity._instance_id = _INSTANCE_ID_GENERATOR.generate()
	return entity


func is_instance() -> bool:
	return _instance_id != ""


func get_entity_id() -> String:
	if is_instance() and _id == "":
		return _get_instanced_from_entity().get_entity_id()
	_initialize_if_not_loaded()
	return _id


func get_entity_name() -> String:
	if is_instance() and _name == "":
		return _get_instanced_from_entity().get_entity_name()
	_initialize_if_not_loaded()
	return tr(_name)


func get_icon_path() -> String:
	if is_instance() and _icon_path == "":
		return _get_instanced_from_entity().get_icon_path()
	_initialize_if_not_loaded()
	if _icon_path != "":
		return _icon_path
	if get_category().get_icon_path() != CATEGORY_ICON_PATH:
		return get_category().get_icon_path()
	return ENTITY_ICON_PATH


func get_icon_color() -> Color:
	if is_instance() and _icon_color == Color.TRANSPARENT:
		return _get_instanced_from_entity().get_icon_color()
	_initialize_if_not_loaded()
	if _icon_color != Color.TRANSPARENT:
		return _icon_color
	if get_category() and get_category().get_icon_color() != Color.TRANSPARENT:
		return get_category().get_icon_color()
	return Color.WHITE


func get_script_path() -> String:
	if is_instance():
		return _get_instanced_from_entity().get_script_path()
	_initialize_if_not_loaded()
	if _script_path != "":
		return _script_path
	if _category_id != "" and get_category() != null:
		return get_category().get_script_path()
	return "res://addons/pandora/model/entity.gd"


func set_entity_name(new_name: String) -> void:
	self._name = new_name
	name_changed.emit(new_name)


func set_icon_path(new_path: String) -> void:
	self._icon_path = new_path
	icon_changed.emit(new_path)


func set_icon_color(new_color: Color) -> void:
	self._icon_color = new_color
	icon_color_changed.emit(new_color)


func set_script_path(new_path: String) -> void:
	self._script_path = new_path
	script_path_changed.emit(new_path)


func set_generate_ids(generate_ids: bool) -> void:
	self._generate_ids = generate_ids
	generate_ids_changed.emit(_generate_ids)


func set_category(category: PandoraCategory) -> void:
	if get_icon_path() != category.get_icon_path():
		if category.get_icon_path() != CATEGORY_ICON_PATH:
			set_icon_path(category.get_icon_path())
		else:
			set_icon_path(ENTITY_ICON_PATH)
	self._category_id = category._id
	category._children.append(self)


func set_index(order: int) -> void:
	self._index = order
	order_changed.emit(order)


func is_generate_ids() -> bool:
	if is_instance():
		return _get_instanced_from_entity().is_generate_ids()
	_initialize_if_not_loaded()
	if self._generate_ids:
		return _generate_ids
	if _category_id != "" and get_category() != null:
		return get_category().is_generate_ids()
	return false


func set_id_generation_class(id_generation_class: String) -> void:
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
	if is_instance():
		return _get_instanced_from_category().get_entity_id()
	_initialize_if_not_loaded()
	return _category_id


func get_entity_property(name: String) -> PandoraProperty:
	if is_instance():
		return _get_instanced_from_entity().get_entity_property(name)
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


func set_string(property_name: String, value: String) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown string property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_integer(property_name: String, value: int) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown integer property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_float(property_name: String, value: float) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown float property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_bool(property_name: String, value: bool) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown bool property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_color(property_name: String, value: Color) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown color property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_reference(property_name: String, value: PandoraEntity) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning(
			"unknown reference property %s on entity %s" % [property_name, get_entity_id()]
		)
	else:
		_set_instance_property(property_name, value)


func set_resource(property_name: String, value: Resource) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_vector2(property_name: String, value: Vector2) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_vector2i(property_name: String, value: Vector2i) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_vector3(property_name: String, value: Vector3) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func set_vector3i(property_name: String, value: Vector3i) -> void:
	if not is_instance():
		push_warning(
			"Pandora: unable to set property - create instance first via PandoraEntity.instantiate()"
		)
		return
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on entity %s" % [property_name, get_entity_id()])
	else:
		_set_instance_property(property_name, value)


func get_string(property_name: String) -> String:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as String
	if not has_entity_property(property_name):
		push_warning("unknown string property %s on entity %s" % [property_name, get_entity_id()])
		return ""
	return get_entity_property(property_name).get_default_value() as String


func get_integer(property_name: String) -> int:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as int
	if not has_entity_property(property_name):
		push_warning("unknown integer property %s on entity %s" % [property_name, get_entity_id()])
		return 0
	# check if property is either int or float, as loading from json
	# auto-converts to float type
	var default_value = get_entity_property(property_name).get_default_value()
	if default_value is float:
		return int(default_value)
	return default_value as int


func get_float(property_name: String) -> float:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as float
	if not has_entity_property(property_name):
		push_warning("unknown float property %s on entity %s" % [property_name, get_entity_id()])
		return 0.0
	return get_entity_property(property_name).get_default_value() as float


func get_bool(property_name: String) -> bool:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as bool
	if not has_entity_property(property_name):
		push_warning("unknown bool property %s on entity %s" % [property_name, get_entity_id()])
		return false
	return get_entity_property(property_name).get_default_value() as bool


func get_color(property_name: String) -> Color:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Color
	if not has_entity_property(property_name):
		push_warning("unknown color property %s on entity %s" % [property_name, get_entity_id()])
		return Color.WHITE
	return get_entity_property(property_name).get_default_value() as Color


func get_reference(property_name: String) -> PandoraEntity:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as PandoraEntity
	if not has_entity_property(property_name):
		push_warning(
			"unknown reference property %s on entity %s" % [property_name, get_entity_id()]
		)
		return null
	return get_entity_property(property_name).get_default_value() as PandoraEntity


func get_resource(property_name: String) -> Resource:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Resource
	if not has_entity_property(property_name):
		push_warning("unknown resource property %s on entity %s" % [property_name, get_entity_id()])
		return null
	return get_entity_property(property_name).get_default_value() as Resource


func get_array(property_name: String) -> Array:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Array
	if not has_entity_property(property_name):
		push_warning("unknown array property %s on entity %s" % [property_name, get_entity_id()])
		return []
	return get_entity_property(property_name).get_default_value() as Array


func get_vector2(property_name: String) -> Vector2:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Vector2
	if not has_entity_property(property_name):
		push_warning("unknown vector2 property %s on entity %s" % [property_name, get_entity_id()])
		return Vector2()
	return get_entity_property(property_name).get_default_value() as Vector2


func get_vector2i(property_name: String) -> Vector2i:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Vector2i
	if not has_entity_property(property_name):
		push_warning("unknown vector2i property %s on entity %s" % [property_name, get_entity_id()])
		return Vector2i()
	return get_entity_property(property_name).get_default_value() as Vector2i


func get_vector3(property_name: String) -> Vector3:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Vector3
	if not has_entity_property(property_name):
		push_warning("unknown vector3 property %s on entity %s" % [property_name, get_entity_id()])
		return Vector3()
	return get_entity_property(property_name).get_default_value() as Vector3


func get_vector3i(property_name: String) -> Vector3i:
	if is_instance() and _instance_properties.has(property_name):
		return _get_instance_property_value(property_name) as Vector3i
	if not has_entity_property(property_name):
		push_warning("unknown vector3i property %s on entity %s" % [property_name, get_entity_id()])
		return Vector3i()
	return get_entity_property(property_name).get_default_value() as Vector3i


func has_entity_property(name: String) -> bool:
	if is_instance():
		return _get_instanced_from_entity().has_entity_property(name)
	_initialize_if_not_loaded()
	return get_entity_property(name) != null


func get_entity_properties() -> Array[PandoraProperty]:
	if is_instance():
		return _get_instanced_from_entity().get_entity_properties()
	var properties: Array[PandoraProperty] = []
	for property in _properties:
		if property.get_category_id() != _id:
			if not _inherited_properties.has(property.get_property_name()):
				_inherited_properties[property.get_property_name()] = OverridingProperty.new(
					self, property
				)
			properties.append(_inherited_properties[property.get_property_name()])
		else:
			properties.append(property)
	return properties


func get_category() -> PandoraCategory:
	if is_instance():
		return _get_instanced_from_category()
	_initialize_if_not_loaded()
	if _category_id == null or _category_id == "":
		return null
	return Pandora.get_category(_category_id)


func get_index() -> int:
	if is_instance():
		return _get_instanced_from_entity().get_index()
	_initialize_if_not_loaded()
	return _index


func is_category(category_id: String) -> bool:
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
	
	
func get_entity_instance_id() -> String:
	return self._instance_id


## Initializes this entity with the given data dictionary.
## Dictionary needs to confirm the structure of this entity.
func load_data(data: Dictionary) -> void:
	if data.has("_id"):
		_id = data["_id"]
	if data.has("_instance_id"):
		_instance_id = data["_instance_id"]
		_instance_properties = _load_instance_properties(data["_instance_properties"])
	else:
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
	if data.has("_icon_color"):
		_icon_color = Color(data["_icon_color"])
	if data.has("_index"):
		_index = data["_index"]
	else:
		_index = 0


## Produces a data dictionary that can be used on load_data()
func save_data() -> Dictionary:
	var dict = {}

	if _id != "":
		dict["_id"] = _id

	if is_instance():
		dict["_instance_id"] = _instance_id
		dict["_instance_properties"] = _save_instance_properties()
	else:
		dict["_name"] = _name
		dict["_category_id"] = _category_id
		dict["_icon_color"] = _icon_color.to_html()

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
	dict["_index"] = _index

	return dict


func _save_overrides() -> Dictionary:
	var output = {}
	for property_name in _property_overrides:
		var value = _property_overrides[property_name]
		var property = get_entity_property(property_name)
		var type = property.get_property_type()
		output[property_name] = {"type": type.get_type_name(), "value": type.write_value(value)}
	return output


func _load_overrides(data: Dictionary) -> Dictionary:
	var output = {}
	for property_name in data:
		var unparsed_data = data[property_name]
		var type = PandoraPropertyType.lookup(unparsed_data["type"])
		output[property_name] = type.parse_value(unparsed_data["value"])
	return output


func _save_instance_properties() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for key in _instance_properties:
		properties.append(_instance_properties[key].save_data())
	return properties


func _load_instance_properties(data: Array) -> Dictionary:
	var properties: Dictionary = {}
	for property_dict in data:
		var property = PandoraPropertyInstance.new(null, "")
		property.load_data(property_dict)
		properties[property.get_property_name()] = property
	return properties


func _delete_property(name: String) -> void:
	if _property_map.has(name):
		_property_map.erase(name)
	_inherited_properties.erase(name)
	_property_overrides.erase(name)
	var original_property: PandoraProperty
	for property in _properties:
		if property.get_property_name() == name:
			original_property = property
	_properties.erase(original_property)


func _to_string() -> String:
	if is_instance():
		return "<PandoraEntity '" + _name + "' instance='true'>"
	else:
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


func _get_instanced_from_entity() -> PandoraEntity:
	if not is_instance():
		return self
	return Pandora.get_entity(self._id)


func _get_instanced_from_category() -> PandoraCategory:
	return _get_instanced_from_entity().get_category()


func _get_instance_property_value(name: String) -> Variant:
	return _instance_properties[name].get_property_value()


func _set_instance_property(name: String, value: Variant) -> void:
	if not is_instance():
		push_error("Cannot set instance property value on a non-instance!")
		return
	var property = get_entity_property(name)
	var default_value = property.get_default_value()
	# value reset to default - clear instance property!
	if default_value == value:
		if _instance_properties.has(name):
			_instance_properties.erase(name)
	# instance property does not exist yet -> create it.
	elif not _instance_properties.has(name):
		var instance_property = PandoraPropertyInstance.new(property, value)
		_instance_properties[name] = instance_property
	else:
		# just set the value
		_instance_properties[name].set_property_value(value)
