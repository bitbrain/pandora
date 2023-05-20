class_name PandoraProperty extends Resource

var _id: String
var _name: String
var _type: String
var _default_value: Variant

func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_type = data["_type"]
	_default_value = data["_default_value"]

func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_name": _name,
		"_type": _type,
		"_default_value": _default_value
	}
