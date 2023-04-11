class_name PandoraDataSyncer extends RefCounted

const ID_FIELD = "_id"
const ModelFactory = preload("res://addons/pandora/model/ModelFactory.gd")

var _cache: PandoraCache
var _backend: PandoraDataBackend
# DataType -> Dictionary
var _create_back_buffer: Dictionary = {}
var _update_back_buffer: Dictionary = {}
var _delete_back_buffer: Dictionary = {}


func _init(cache: PandoraCache, backend: PandoraDataBackend):
	_cache = cache
	_backend = backend
	_cache.entry_created.connect(_on_entry_created)
	_cache.entry_updated.connect(_on_entry_updated)
	_cache.entry_deleted.connect(_on_entry_deleted)
	

func _on_entry_created(data_type:String, key:String, data:PandoraIdentifiable) -> void:
	if not data_type in _create_back_buffer:
		_create_back_buffer[data_type] = {}
	_create_back_buffer[data_type][key] = data


func _on_entry_deleted(data_type:String, key:String, data:PandoraIdentifiable) -> void:
	if not data_type in _update_back_buffer:
		_update_back_buffer[data_type] = {}
	_update_back_buffer[data_type][key] = data


func _on_entry_updated(data_type:String, key:String, data:PandoraIdentifiable) -> void:
	if not data_type in _delete_back_buffer:
		_delete_back_buffer[data_type] = {}
	_delete_back_buffer[data_type][key] = data
	
	
func warm_up(data_type:String) -> void:
	var context_id = Pandora.get_context_manager().get_context_id()
	# retrieve all existing data from disk
	var data_by_ids = _backend.get_all_data(data_type, context_id)
	for key in data_by_ids:
		var entity = ModelFactory.create_from_data_type(data_type)
		if entity != null:
			entity.load_data(data_by_ids[key])
			_cache.set_entry(key, entity, data_type, false)
		else:
			print("Unsupported data type:", data_type)

func flush(data_type:String) -> void:
	var context_id = Pandora.get_context_manager().get_context_id()
	# retrieve all existing data from disk
	var data_by_ids = _backend.get_all_data(data_type, context_id)
	
	if _create_back_buffer.has(data_type):
		var entities_to_add = _create_back_buffer[data_type]
		for entity_id in entities_to_add:
			data_by_ids[entity_id] = entities_to_add[entity_id].save_data()
			
	if _update_back_buffer.has(data_type):
		var entities_to_update = _update_back_buffer[data_type]
		for entity_id in entities_to_update:
			data_by_ids[entity_id] = entities_to_update[entity_id].save_data()
			
	if _delete_back_buffer.has(data_type):
		var entities_to_update = _delete_back_buffer[data_type]
		for entity_id in _delete_back_buffer:
			data_by_ids.erase(entity_id)
			
	_backend.store_all_data(data_type, data_by_ids, context_id)
	

func _convert_to_dict(identifiables:Array) -> Array[Dictionary]:
	var result:Array[Dictionary] = []
	for identifiable in identifiables:
		if identifiable is PandoraIdentifiable:
			result.append(identifiable.save_data())
	return result
