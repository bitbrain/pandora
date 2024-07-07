## Generic definition of a Pandora storage.
## Provides a generic way to persist and load
## data required for this addon.
class_name PandoraDataStorage extends RefCounted

var DEFAULT_ICON = preload("res://addons/pandora/icons/pandora-icon.svg")


func get_storage_name() -> String:
	return "missing storage name"


func get_storage_description() -> String:
	return "missing description"


func get_storage_icon() -> Texture:
	return DEFAULT_ICON


func store_all_data(data: Dictionary, context_id: String) -> Dictionary:
	return {}


func get_all_data(context_id: String) -> Dictionary:
	return {}


func load_from_file(file_path: String) -> Dictionary:
	return {}
