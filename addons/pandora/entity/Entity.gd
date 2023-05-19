class_name PandoraEntity extends Resource


var _id:String
var _name:String
var _icon_path:String
	


func load_data(data:Dictionary) -> void:
	_id = data["_id"]
	_name = data["_name"]
	_icon_path = data["_icon_path"]
	
	
func save_data() -> Dictionary:
	return {
		"_id": _id,
		"_name": _name,
		"_icon_path": _icon_path
	}
	
