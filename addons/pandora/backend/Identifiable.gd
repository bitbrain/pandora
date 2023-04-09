class_name PandoraIdentifiable extends PandoraSerializable

const Hash = preload("res://addons/pandora/utils/Hash.gd")
const DictionaryUtils = preload("res://addons/pandora/utils/DictionaryUtils.gd")

var _id:String

func get_id() -> String:
	return _id
	
func hash_value() -> int:
	return Hash.hash_attributes([_id])
	
func load_data(data:Dictionary) -> void:
	_id = data["_id"]


func save_data() -> Dictionary:
	return {
		"_id": _id
	}
