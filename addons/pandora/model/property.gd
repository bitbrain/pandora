class_name PandoraProperty extends Resource

var _id: String
var _name: String
var _type: String
var _default_value: Variant


func _init(id:String, name:String, type:String, default_value:Variant) -> void:
	self._id = id
	self._name = name
	self._type = type
	self._default_value = default_value
	
	
func get_property_id() -> String:
	return _id
	
	
func get_property_name() -> String:
	return _name
	
	
func get_property_type() -> String:
	return _type
	
	
func get_default_value() -> String:
	return _default_value


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_type = data["_type"]
	_default_value = parse_value(data["_default_value"], _type)

func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_name": _name,
		"_type": _type,
		"_default_value": str(_default_value)
	}


static func parse_value(value:String, type:String) -> Variant:
	if type == "string":
		return value
	if type == "int":
		return int(value)
	if type == "bool":
		return bool(int(value))
	if type == "float":
		return float(value)
	push_error("Unsupported variant type of value %s" % str(type))
	return ""
	
	
static func type_of(variant:Variant) -> String:
	if variant is String:
		return "string"
	if variant is int:
		return "int"
	if variant is bool:
		return "bool"
	if variant is float:
		return "float"
	push_error("Unsupported variant type of value %s" % str(variant))
	return ""
