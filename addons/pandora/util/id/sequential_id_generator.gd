class_name PandoraSequentialIDGenerator
extends PandoraIDGenerator


const DEFAULT_CONTEXT := "default"


var _context: String
var _ids_by_context: Dictionary = {}


func _init(context: String = DEFAULT_CONTEXT):
	_context = context


func generate() -> String:
	if not _ids_by_context.has(_context):
		_ids_by_context[_context] = 0
	_ids_by_context[_context] += 1
	return str(_ids_by_context[_context])


func clear() -> void:
	_ids_by_context.clear()


func save_data() -> Dictionary:
	return {
		"_ids_by_context": _ids_by_context
	}


func load_data(data: Dictionary) -> void:
	_ids_by_context = data["_ids_by_context"]
