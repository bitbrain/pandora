class_name PandoraEntityInstance extends Resource


var _id:String
var _entity_id:String
# Dictionary[String, PandoraInstanceProperty]
var _properties:Dictionary = {}


func _init(id:String, entity_id:String, properties:Array[PandoraPropertyInstance]) -> void:
	self._id = id
	self._entity_id = entity_id
	for property in properties:
		self._properties[property.get_property_id()] = property
		
		
func get_string(property_name:String) -> String:
	if not _properties.has(property_name):
		push_error("unknown string property %s on instance %s" % [property_name, _id])
		return ""
	if not _properties[property_name] is String:
		push_error("property %s on instance %s is not a string" % [property_name, _id])
		return ""
	return _properties[property_name] as String
	
	
func get_integer(property_name:String) -> int:
	if not _properties.has(property_name):
		push_error("unknown string property %s on instance %s" % [property_name, _id])
		return 0
	if not _properties[property_name] is int:
		push_error("property %s on instance %s is not an int" % [property_name, _id])
		return 0
	return _properties[property_name] as int
	
	
func get_float(property_name:String) -> float:
	if not _properties.has(property_name):
		push_error("unknown string property %s on instance %s" % [property_name, _id])
		return 0.0
	if not _properties[property_name] is float:
		push_error("property %s on instance %s is not a float" % [property_name, _id])
		return 0.0
	return _properties[property_name] as float
	
	
func get_bool(property_name:String) -> bool:
	if not _properties.has(property_name):
		push_error("unknown string property %s on instance %s" % [property_name, _id])
		return false
	if not _properties[property_name] is bool:
		push_error("property %s on instance %s is not a bool" % [property_name, _id])
		return false
	return _properties[property_name] as bool


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_entity_id = data["_entity_id"]
	_properties = _load_properties(data["_properties"])
	
	
func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_entity_id": _entity_id,
		"_properties": _save_properties(_properties),
	}
	
	
func _save_properties(data:Dictionary) -> Array[Dictionary]:
	var properties:Array[Dictionary] = []
	for key in data:
		properties.append(data[key].save_data())
	return properties
	
	
func _load_properties(data:Array) -> Dictionary:
	var properties:Dictionary = {}
	for property_dict in data:
		var property = PandoraPropertyInstance.new("", "", "")
		property.load_data(property_dict)
		properties[property.get_property_instance_id()] = property
	return properties
	
