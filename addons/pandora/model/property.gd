## A property contains a Variant that can be accessed
## across Pandora by id. Properties can be shared between
## different entities (depending on the way they get inherited).
## This ensures that changing the original property will automatically
## apply to any other entity that is using it.
class_name PandoraProperty extends RefCounted

## Emitted when the name of this property changed.
signal name_changed(old_name: String, new_name: String)
signal setting_changed(key: String)
signal setting_cleared(key: String)

var _id: String
var _name: String:
	set(n):
		var old = _name
		_name = n
		if _name != old:
			name_changed.emit(old, _name)
var _type: PandoraPropertyType
var _default_value: Variant
var _category_id: String
# setting name -> Variant
var _setting_overrides: Dictionary = {}


func _init(id: String, name: String, type_name: String) -> void:
	self._id = id
	self._name = name
	self._type = PandoraPropertyType.lookup(type_name)
	self._default_value = _type.get_default_value()


func get_setting(key: String) -> Variant:
	if has_setting_override(key):
		return _setting_overrides[key]
	elif _type != null:
		return _type.get_settings()[key]["value"]
	else:
		return null


func get_setting_override(name: String) -> Variant:
	if _setting_overrides.has(name):
		return _setting_overrides[name]
	return null


func has_setting_override(name: String) -> bool:
	return _setting_overrides.has(name)


func set_setting_override(name: String, override: Variant) -> void:
	_setting_overrides[name] = override
	setting_changed.emit(name)


func clear_setting_override(name: String) -> void:
	_setting_overrides.erase(name)
	setting_cleared.emit(name)


func set_default_value(value: Variant) -> void:
	if not _type.is_valid(value):
		print("Pandora error: value " + str(value) + " is incompatible with type ", _type)
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
	_default_value = value


func get_property_id() -> String:
	return _id


func get_property_name() -> String:
	return _name


func get_property_type() -> PandoraPropertyType:
	return _type


func get_default_value() -> Variant:
	if _default_value is PandoraReference:
		return _default_value.get_entity()
	return _default_value


func get_category_id() -> String:
	return _category_id


## the original category id specifies
## the category where this property has
## been originally defined (and inherited down)
func get_original_category_id() -> String:
	return _category_id


## resets this property to its original
## default value in case it was overridden
func reset_to_default() -> void:
	pass


## true in case this property is the original definition
## of a property. (not inherited)
func is_original() -> bool:
	return true


## returns true when this property is currently overridden
func is_overridden() -> bool:
	return false


func load_data(data: Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_type = PandoraPropertyType.lookup(data["_type"])
	_category_id = data["_category_id"]
	if data.has("_setting_overrides"):
		_setting_overrides = data["_setting_overrides"]
		_default_value = _type.parse_value(data["_default_value"], data["_setting_overrides"])
	else:
		_default_value = _type.parse_value(data["_default_value"])


func save_data() -> Dictionary:
	var data = {
		"_id": _id,
		"_name": _name,
		"_type": _type.get_type_name(),
		"_default_value": _type.write_value(_default_value),
		"_category_id": _category_id,
	}
	if not _setting_overrides.is_empty():
		data["_setting_overrides"] = _setting_overrides
	return data


func equals(other: PandoraProperty) -> bool:
	return (
		get_property_id() == other.get_property_id()
		and get_property_name() == other.get_property_name()
		and get_property_type() == other.get_property_type()
	)


func _to_string() -> String:
	return (
		"<PandoraProperty '"
		+ get_property_name()
		+ "' ("
		+ get_property_type().get_type_name()
		+ ")>"
	)
