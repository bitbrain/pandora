class_name PandoraPropertyInstance extends Resource

var _id: String
var _property_id: String
var _value: Variant
# not persisted -> set at runtime
var _property:PandoraProperty

func _init(id:String, _property:PandoraProperty, value:Variant) -> void:
	self._id = id
	if _property != null:
		self._property_id = _property.get_property_id()
	self._value = value
	self._property = _property
	
	
func get_property_instance_id() -> String:
	return _id
	
	
func get_property_name() -> String:
	return _property.get_property_name()


func get_property_id() -> String:
	return _property_id


func get_property_value() -> Variant:
	return _value


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_value = data["_property_id"]


func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_property_id": _property_id,
		"_value": _value
	}
