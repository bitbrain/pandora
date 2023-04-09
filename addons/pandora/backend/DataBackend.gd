## Generic definition of a Pandora backend.
## Provides a generic way to persist and load
## data required for this addon.
class_name PandoraDataBackend extends RefCounted


func get_name() -> String:
	return "missing backend name"
	
	
func get_description() -> String:
	return "missing description"
	
	
func get_icon() -> Texture:
	return null


## called when saving a list of serializables
func save_all(serializables:Array[PandoraSerializable]) -> bool:
	return false


## called whenever items need to be loaded
func load_all(filters:Array[Callable] = []) -> Array[PandoraSerializable]:
	return []
