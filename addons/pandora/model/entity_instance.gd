class_name PandoraEntityInstance extends RefCounted


var _entity_id:String
# Dictionary[String, PandoraInstanceProperty]
var _properties:Dictionary = {}


func _init(entity_id:String, properties:Array[PandoraPropertyInstance]) -> void:
	self._entity_id = entity_id
	for property in properties:
		self._properties[property.get_property_name()] = property


func get_entity() -> PandoraEntity:
	return Pandora.get_entity(_entity_id)
	
	
func get_icon() -> Texture:
	return load(get_entity().get_icon_path())
	
	
func get_entity_name() -> String:
	return get_entity().get_entity_name()
	
	
func get_entity_id() -> String:
	return get_entity().get_entity_id()
	
	
func get_category() -> PandoraCategory:
	return get_entity().get_category()
	
	
func has_same_entity(instance:PandoraEntityInstance) -> bool:
	return get_entity_id() == instance.get_entity_id()

		
func get_string(property_name:String) -> String:
	if not _properties.has(property_name):
		push_warning("unknown string property %s on instance %s" % [property_name, get_instance_id()])
		return ""
	if not _get_property_value(property_name) is String:
		push_error("property %s on instance %s is not a string" % [property_name, get_instance_id()])
		return ""
	return _get_property_value(property_name) as String
	
	
func get_integer(property_name:String) -> int:
	if not _properties.has(property_name):
		push_warning("unknown integer property %s on instance %s" % [property_name, get_instance_id()])
		return 0
	if not _get_property_value(property_name) is int:
		push_error("property %s on instance %s is not an int" % [property_name, get_instance_id()])
		return 0
	return _get_property_value(property_name) as int
	
	
func get_float(property_name:String) -> float:
	if not _properties.has(property_name):
		push_warning("unknown float property %s on instance %s" % [property_name, get_instance_id()])
		return 0.0
	if not _get_property_value(property_name) is float:
		push_error("property %s on instance %s is not a float" % [property_name, get_instance_id()])
		return 0.0
	return _get_property_value(property_name) as float
	
	
func get_bool(property_name:String) -> bool:
	if not _properties.has(property_name):
		push_warning("unknown bool property %s on instance %s" % [property_name, get_instance_id()])
		return false
	if not _get_property_value(property_name) is bool:
		push_error("property %s on instance %s is not a bool" % [property_name, get_instance_id()])
		return false
	return _get_property_value(property_name) as bool
	
	
func get_color(property_name:String) -> Color:
	if not _properties.has(property_name):
		push_warning("unknown color property %s on instance %s" % [property_name, get_instance_id()])
		return Color.WHITE
	if not _get_property_value(property_name) is Color:
		push_error("property %s on instance %s is not a bool" % [property_name, get_instance_id()])
		return Color.WHITE
	return _get_property_value(property_name) as Color
	
	
func set_string(property_name:String, value:String) -> void:
	if not _properties.has(property_name):
		push_warning("unknown string property %s on instance %s" % [property_name, get_instance_id()])
	else:
		_properties[property_name].set_property_value(value)


func set_integer(property_name:String, value:int) -> void:
	if not _properties.has(property_name):
		push_warning("unknown integer property %s on instance %s" % [property_name, get_instance_id()])
	else:
		_properties[property_name].set_property_value(value)


func set_float(property_name:String, value:float) -> void:
	if not _properties.has(property_name):
		push_warning("unknown float property %s on instance %s" % [property_name, get_instance_id()])
	else:
		_properties[property_name].set_property_value(value)


func set_bool(property_name:String, value:bool) -> void:
	if not _properties.has(property_name):
		push_warning("unknown bool property %s on instance %s" % [property_name, get_instance_id()])
	else:
		_properties[property_name].set_property_value(value)


func set_color(property_name:String, value:Color) -> void:
	if not _properties.has(property_name):
		push_warning("unknown color property %s on instance %s" % [property_name, get_instance_id()])
	else:
		_properties[property_name].set_property_value(value)


func load_data(data:Dictionary) -> void:
	_entity_id = data["_entity_id"]
	_properties = _load_properties(data["_properties"])
	
	
func save_data() -> Dictionary:
	return {
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
		var property = PandoraPropertyInstance.new(null, "")
		property.load_data(property_dict)
		properties[property.get_property_name()] = property
	return properties
	
	
func _get_property_value(name:String) -> Variant:
	return _properties[name].get_property_value()
