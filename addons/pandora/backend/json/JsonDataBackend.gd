@tool
class_name PandoraJsonDataBackend extends PandoraDataBackend

const ICON = preload("res://addons/pandora/icons/pandora-json-icon.svg")


var data_directory: String = "user://pandora"


func _init(data_dir: String):
	data_directory = data_dir


func create_all_data(data_type: String, data: Array[Dictionary], context_id: String) -> Array[Dictionary]:
	var file_path = _get_file_path(data_type, context_id)
	_add_to_file(file_path, data)
	return data


func update_all_data(data_type: String, data: Array[Dictionary], context_id: String) -> void:
	var file_path = _get_file_path(data_type, context_id)
	_replace_in_file(file_path, data)


func delete_all_data(data_type: String, data_ids: Array[String], context_id: String) -> void:
	var file_path = _get_file_path(data_type, context_id)
	# TODO implement me


func get_data_list(data_type: String, data_ids: Array, context_id: String) -> Array:
	var result = []
	for data_id in data_ids:
		pass
		# TODO implement me
	return result


func get_all_data(data_type: String, context_id: String) -> Array:
	var result = []
	var dir_path = _get_directory_path(data_type, context_id)
	var directory = DirAccess.open(dir_path)
	if directory != null:
		directory.list_dir_begin()
		var file_name = directory.get_next()
		while file_name != "":
			if !directory.current_is_dir():
				var file_path = "%s/%s" % [dir_path, file_name]
				var data = _load_from_file(file_path)
				result.append(data)
			file_name = directory.get_next()
		directory.list_dir_end()

	return result


func _get_directory_path(data_type: String, context_id: String) -> String:
	var directory_path = "%s/%s" % [data_directory, context_id]
	if not DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_recursive_absolute(directory_path)
	return "%s/%s" % [directory_path, data_type]


func _get_file_path(data_type: String, context_id: String) -> String:
	return "%s.json" % [_get_directory_path(data_type, context_id)]



func _add_to_file(file_path: String, data: Array[Dictionary]) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.new()
	file.store_string(json.stringify(data))
	file.close()
	

# TODO FIXME
func _replace_in_file(file_path: String, data: Array[Dictionary]) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.new()
	file.store_string(json.print(data))
	file.close()


func _load_from_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if FileAccess.file_exists(file_path) and file != null:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		json.parse(content)
		return json.get_data()
	else:
		return {}
