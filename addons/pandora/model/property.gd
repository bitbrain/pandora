class_name PandoraProperty extends Resource


var _id: String
var _name: String
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

	
static func write_value(value:Variant) -> String:
	if value is Color:
		var color = value as Color
		return color.to_html()
	if value is bool:
		return "1" if value else "0"
	return str(value)


static func parse_value(value:String, type:String) -> Variant:
	if type == "string":
		return value
	if type == "int":
		return int(value)
	if type == "bool":
		return bool(int(value))
	if type == "float":
		return float(value)
	if type == "color":
		return Color.from_string(value, Color.WHITE)
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
	push_error("Unsupported variant type %s" % str(type))
	return ""
