## Custom properties that also contain type information 
class_name PandoraCustomProperties extends PandoraSerializable

const Hash = preload("res://addons/pandora/utils/Hash.gd")


var _properties:Dictionary
var _types:Dictionary


func hash_value() -> int:
	return Hash.hash_attributes([_properties, _types])


func load_data(data:Dictionary) -> void:
	_types = data["_types"]
	_properties = data["_properties"]


func save_data() -> Dictionary:
	return {
		"_types": _types,
		"_properties": _properties
	}
