class_name PandoraPropertyInstance extends Resource

var _id: String
var _property_id: String
var _value: Variant


func _init(id:String, property_id:String, value:Variant) -> void:
	self._id = id
	self._property_id = property_id
	self._value = value
	
	
func get_property_instance_id() -> String:
	return _id


func get_property_id() -> String:
	return _property_id
	

func get_value() -> Variant:
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
