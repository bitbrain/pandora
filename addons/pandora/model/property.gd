## A property contains a Variant that can be accessed
## across Pandora by id. Properties can be shared between
## different entities (depending on the way they get inherited).
## This ensures that changing the original property will automatically
## apply to any other entity that is using it.
class_name PandoraProperty extends Resource


static var _TYPE_CHECKS = {
	"string": func(variant): return variant is String,
	"int": func(variant): return variant is int,
	"float": func(variant): return variant is float,
	"bool": func(variant): return variant is bool,
	"color": func(variant): return variant is Color or variant is String,
	"reference": func(variant): return variant is PandoraEntity,
	"resource": func(variant): return variant is Resource
}


## Emitted when the name of this property changed.
signal name_changed(old_name:String, new_name:String)
signal setting_changed(key:String)
signal setting_cleared(key:String)


var _id: String
var _name: String:
	set(n):
		var old = _name
		_name = n
		if _name != old:
			name_changed.emit(old, _name)
var _type: String
var _default_value: Variant
var _category_id:String
# setting name -> Variant
var _setting_overrides:Dictionary = {}


func _init(id:String, name:String, type:String, default_value:Variant) -> void:
	self._id = id
	self._name = name
	self._type = type
	if self._type and not is_valid_type(default_value):
		print("Pandora error: value " + str(default_value) + " is incompatible with type ", type)
	else:
		self._default_value = default_value
	
	
func get_setting_override(name:String) -> Variant:
	if _setting_overrides.has(name):
		return _setting_overrides[name]
	return null
	
	
func has_setting_override(name:String) -> Variant:
	return _setting_overrides.has(name)
	
	
func set_setting_override(name:String, override:Variant) -> void:
	_setting_overrides[name] = override
	setting_changed.emit(name)
	
	
func clear_setting_override(name:String) -> void:
	_setting_overrides.erase(name)
	setting_cleared.emit(name)


func set_default_value(value:Variant) -> void:
	if not is_valid_type(value):
		print("Pandora error: value " + str(value) + " is incompatible with type ", _type)
		return
	# ensure that a supported type is assigned.
	if value is PandoraEntity:
		value = PandoraReference.new(value.get_entity_id(), PandoraReference.Type.CATEGORY if value is PandoraCategory else PandoraReference.Type.ENTITY)
	_default_value = value


func get_property_id() -> String:
	return _id


func get_property_name() -> String:
	return _name


func get_property_type() -> String:
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


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_type = data["_type"]
	_default_value = parse_value(data["_default_value"], _type)
	_category_id = data["_category_id"]
	if data.has("_setting_overrides"):
		_setting_overrides = data["_setting_overrides"]


func save_data() -> Dictionary:
	var data = {
		"_id": _id,
		"_name": _name,
		"_type": _type,
		"_default_value": write_value(_default_value),
		"_category_id": _category_id,
	}
	if not _setting_overrides.is_empty():
		data["_setting_overrides"] = _setting_overrides
	return data

	
static func write_value(value:Variant) -> Variant:
	if value == null:
		return null
	if value is Color:
		var color = value as Color
		return color.to_html()
	if value is PandoraReference:
		return value.save_data()
	if value is Resource:
		return value.resource_path
	return value


static func parse_value(value, type:String) -> Variant:
	if value == null:
		return null
	if type == "color" and value is String:
		return Color.from_string(value, Color.WHITE)
	if type == "reference" and value is Dictionary:
		var reference = PandoraReference.new("", 0)
		reference.load_data(value)
		return reference
	if type == "resource" and value is String:
		return load(value)
	return value
	
	
static func default_value_of(type:String) -> Variant:
	if type == "string":
		return "Property Value"
	if type == "int":
		return 0
	if type == "bool":
		return false
	if type == "float":
		return 0.0
	if type == "color":
		return Color.WHITE
	if type == "reference":
		return null
	if type == "resource":
		return null
	push_error("Unsupported variant type %s" % str(type))
	return ""


func is_valid_type(variant:Variant) -> bool:
	if not _TYPE_CHECKS or not _TYPE_CHECKS.has(get_property_type()):
		return false
	return variant == null or _TYPE_CHECKS[get_property_type()].call(variant)
