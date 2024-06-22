class_name PandoraReference extends RefCounted

enum Type { ENTITY, CATEGORY }

var _entity_id: String
var _type: Type


func _init(entity_id: String, type: Type) -> void:
	_entity_id = entity_id
	_type = type


func get_entity() -> PandoraEntity:
	if _type == Type.ENTITY:
		return Pandora.get_entity(_entity_id)
	else:
		return Pandora.get_category(_entity_id)


func load_data(data: Dictionary) -> void:
	_entity_id = data["_entity_id"]
	if data.has("_type"):
		_type = data["_type"]
	else:
		_type = Type.ENTITY


func save_data() -> Dictionary:
	return {"_entity_id": _entity_id, "_type": _type}


func _to_string() -> String:
	return "<PandoraReference" + str(get_entity()) + ">"
