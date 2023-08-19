class_name PandoraIdGenerator extends RefCounted


const DEFAULT_CONTEXT = "default"

# string -> int
var _ids_by_context:Dictionary = {}


func generate(context:String = DEFAULT_CONTEXT) -> String:
	if not _ids_by_context.has(context):
		_ids_by_context[context] = 0
	_ids_by_context[context] += 1
	return str(_ids_by_context[context])
	

func clear() -> void:
	_ids_by_context.clear()


func load_data(data:Dictionary) -> void:
	_ids_by_context = data["_ids_by_context"]
	
	
func save_data() -> Dictionary:
	return {
		"_ids_by_context": _ids_by_context
	}
