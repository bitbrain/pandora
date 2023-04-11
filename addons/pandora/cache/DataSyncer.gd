class_name PandoraDataSyncer extends RefCounted


var _cache: PandoraCache
var _backend: PandoraDataBackend
# DataType -> Array[PandoraIdentifiable]
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
		var empty_array:Array[PandoraIdentifiable] = []
		_create_back_buffer[data_type] = empty_array
	_create_back_buffer[data_type].append(data)


func _on_entry_deleted(data_type:String, key:String, data:PandoraIdentifiable) -> void:
	if not data_type in _update_back_buffer:
		var empty_array:Array[PandoraIdentifiable] = []
		_update_back_buffer[data_type] = empty_array
	_update_back_buffer[data_type].append(data)


func _on_entry_updated(data_type:String, key:String, data:PandoraIdentifiable) -> void:
	if not data_type in _delete_back_buffer:
		var empty_array:Array[PandoraIdentifiable] = []
		_delete_back_buffer[data_type] = empty_array
	_delete_back_buffer[data_type].append(data)


func flush(data_type:String = "") -> void:
	var context_id = Pandora.get_context_manager().get_context_id()
	_flush_create_buffer(context_id, data_type)
	_flush_update_buffer(context_id, data_type)
	_flush_delete_buffer(context_id, data_type)

	
func _flush_create_buffer(context_id:String, data_type_filter:String = "") -> void:
	for data_type in _create_back_buffer:
		if data_type_filter != "" and data_type_filter != data_type:
			# skip anything that does not match the data type
			continue
		var data = _convert_to_dict(_create_back_buffer[data_type])
		_backend.create_all_data(data_type, data, context_id)
	if data_type_filter != "":
		_create_back_buffer.erase(data_type_filter)
	else:
		_create_back_buffer.clear()


func _flush_update_buffer(context_id:String, data_type_filter:String = "") -> void:
	for data_type in _update_back_buffer:
		if data_type_filter != "" and data_type_filter != data_type:
			# skip anything that does not match the data type
			continue
		var data = _convert_to_dict(_update_back_buffer[data_type])
		_backend.update_all_data(data_type, data, context_id)
	if data_type_filter != "":
		_update_back_buffer.erase(data_type_filter)
	else:
		_update_back_buffer.clear()
	
	
func _flush_delete_buffer(context_id:String, data_type_filter:String = "") -> void:
	for data_type in _delete_back_buffer:
		if data_type_filter != "" and data_type_filter != data_type:
			# skip anything that does not match the data type
			continue
		var ids = _convert_to_ids(_delete_back_buffer[data_type])
		_backend.delete_all_data(data_type, ids, context_id)
	if data_type_filter != "":
		_delete_back_buffer.erase(data_type_filter)
	else:
		_delete_back_buffer.clear()


func _convert_to_dict(identifiables:Array) -> Array[Dictionary]:
	var result:Array[Dictionary] = []
	for identifiable in identifiables:
		if identifiable is PandoraIdentifiable:
			result.append(identifiable.save_data())
	return result


func _convert_to_ids(identifiables:Array) -> Array[String]:
	var result = []
	for identifiable in identifiables:
		if identifiable is PandoraIdentifiable:
			result.append(identifiable.get_id())
	return result
