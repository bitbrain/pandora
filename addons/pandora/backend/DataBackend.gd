## Generic definition of a Pandora backend.
## Provides a generic way to persist and load
## data required for this addon.
class_name PandoraDataBackend extends RefCounted


var DEFAULT_ICON = preload("res://addons/pandora/icons/pandora-icon.svg")


func get_backend_name() -> String:
	return "missing backend name"
	
	
func get_backend_description() -> String:
	return "missing description"
	
	
func get_backend_icon() -> Texture:
	return DEFAULT_ICON


func store_all_data(data_type: String, data: Dictionary, context_id: String) -> Dictionary:
	return {}


func get_all_data(data_type: String, context_id: String) -> Dictionary:
	return {}
