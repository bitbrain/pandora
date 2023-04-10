## Generic definition of a Pandora backend.
## Provides a generic way to persist and load
## data required for this addon.
class_name PandoraDataBackend extends Node


func get_backend_name() -> String:
	return "missing backend name"
	
	
func get_backend_description() -> String:
	return "missing description"
	
	
func get_backend_icon() -> Texture:
	return null


## called when saving a list of serializables
func save_all(serializables:Array[PandoraIdentifiable]) -> void:
	pass


## Loads PandoraIdentifiable by ids
func load_by_ids(ids:Array[String]) -> Dictionary:
	return {}


## called whenever items need to be loaded
func load_all(filters:Array[Callable] = []) -> Array[PandoraIdentifiable]:
	return []


## Flushes the saved data to disk
func flush() -> bool:
	return false
