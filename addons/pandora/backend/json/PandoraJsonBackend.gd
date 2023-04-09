class_name PandoraJsonBackend extends PandoraDataBackend

const ICON = preload("res://addons/pandora/icons/pandora-json-icon.svg")
const DIRECTORY = "pandora"
const FILE_NAME_ITEM = "items.json"
const FILE_NAME_ITEM_BLUEPRINT = "item-blueprints.json"

func get_name() -> String:
	return "Pandora default (json)"
	
	
func get_description() -> String:
	return "Persists data via json files."
	
	
func get_icon() -> Texture:
	return ICON


func save_all(serializables:Array[PandoraSerializable]) -> bool:
	var dict = {}
	
	return false


func load_all(filters:Array[Callable] = []) -> Array[PandoraSerializable]:
	return []


func _save_to_file(data:Dictionary, file:String) -> void:
	pass
	
func _load_from_file(file:String) -> Dictionary:
	return {}
