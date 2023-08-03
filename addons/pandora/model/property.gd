## A property contains a Variant that can be accessed
## across Pandora by id. Properties can be shared between
## different entities (depending on the way they get inherited).
## This ensures that changing the original property will automatically
## apply to any other entity that is using it.
class_name PandoraProperty extends Resource


## Emitted when the name of this property changed.
signal name_changed(old_name:String, new_name:String)


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


func _init(id:String, name:String, type:String, default_value:Variant) -> void:
	self._id = id
	self._name = name
	self._type = type
	self._default_value = default_value


func set_default_value(value:Variant) -> void:
	_default_value = value


func get_property_id() -> String:
	return _id


func get_property_name() -> String:
	return _name


func get_property_type() -> String:
	return _type


func get_default_value() -> Variant:
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


func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_name": _name,
		"_type": _type,
		"_default_value": write_value(_default_value),
		"_category_id": _category_id,
	}

	
static func write_value(value:Variant):
	if value == null:
		return null
	if value is Color:
		var color = value as Color
		return color.to_html()
	if value is bool:
		return "1" if value else "0"
	if value is PandoraReference:
		return value.save_data()
	if value is Resource:
		return value.resource_path
	return str(value)


static func parse_value(value, type:String) -> Variant:
	if value == null:
		return null
	if type == "string" and value is String:
		return value
	if type == "int" and value is String:
		return int(value)
	if type == "bool" and value is String:
		return bool(int(value))
	if type == "float" and value is String:
		return float(value)
	if type == "color" and value is String:
		return Color.from_string(value, Color.WHITE)
	if type == "reference" and value is Dictionary:
		var reference = PandoraReference.new("")
		reference.load_data(value)
		return reference
	if type == "resource" and value is String:
		return load(value)
	push_error("Unsupported variant type of value %s" % str(type))
	return ""
	
	
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
		return PandoraReference.new("1234")
	if type == "resource":
		return null
	push_error("Unsupported variant type %s" % str(type))
	return ""
