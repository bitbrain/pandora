class_name PandoraReference extends Resource


var _entity_id:String


func _init(entity_id:String) -> void:
	_entity_id = entity_id
	
	
func get_entity() -> PandoraEntity:
	return Pandora.get_entity(_entity_id)


func load_data(data:Dictionary) -> void:
	_entity_id = data["_entity_id"]


func save_data() -> Dictionary:
	return {
		"_entity_id": _entity_id
	}
