## Implementation of a cache based on a Least accessed eviction policy.
## If the cache is full and we want to persist a new element, the element
## that was accessed the longest time ago will be evicted from the cache.
class_name PandoraLeastAccessedCache extends PandoraCache


var _max_size: int
# DataType -> ID -> Entity
var _data: Dictionary
var _access_times: Dictionary


func _init(max_size: int):
	_max_size = max_size
	_data = {}
	_access_times = {}
	
	
func get_all_entries(data_type:String) -> Array[PandoraIdentifiable]:
	var result:Array[PandoraIdentifiable] = []
	var entities = _data[data_type]
	for key in entities:
		result.append(get_entry(key, data_type))
	return result


func get_entry(key: String, data_type: String) -> PandoraIdentifiable:
	if data_type in _data and key in _data[data_type]:
		_access_times[data_type][key] = Time.get_unix_time_from_system()
		return _data[data_type][key]
	return null


func set_entry(key: String, value: PandoraIdentifiable, data_type: String, send_signal = true) -> void:
	if data_type not in _data:
		_data[data_type] = {}
		_access_times[data_type] = {}
	if key in _data[data_type]:
		_data[data_type][key] = value
		_access_times[data_type][key] = Time.get_unix_time_from_system()
		if send_signal:
			entry_updated.emit(data_type, key, value)
	elif size() < _max_size:
		_data[data_type][key] = value
		_access_times[data_type][key] = Time.get_unix_time_from_system()
		if send_signal:
			entry_created.emit(data_type, key, value)
	else:
		_evict_least_accessed(data_type)
		_data[data_type][key] = value
		_access_times[data_type][key] = Time.get_unix_time_from_system()
		if send_signal:
			entry_updated.emit(data_type, key, value)


func delete_entry(key: String, data_type: String) -> void:
	if data_type in _data and key in _data[data_type]:
		var data = _data[data_type].get(key)
		_data[data_type].erase(key)
		_access_times[data_type].erase(key)
		entry_deleted.emit(data_type, key, data)


func clear() -> void:
	_data = {}
	_access_times = {}


func _evict_least_accessed(data_type: String) -> void:
	var least_accessed_key = null
	var least_accessed_time = INF
	for key in _access_times[data_type]:
		if _access_times[data_type][key] < least_accessed_time:
			least_accessed_time = _access_times[data_type][key]
			least_accessed_key = key
	if least_accessed_key != null:
		_data[data_type].erase(least_accessed_key)
		_access_times[data_type].erase(least_accessed_key)


func size(data_type: String = "") -> int:
	if data_type == "":
		var total_size = 0
		for dt in _data:
			total_size += _data[dt].size()
		return total_size
	elif data_type in _data:
		return _data[data_type].size()
	return 0
