@tool
class_name PandoraJsonDataStorage extends PandoraDataStorage

const ICON = preload("res://addons/pandora/icons/pandora-json-icon.svg")

var data_directory: String = "user://pandora"


func get_backend_name() -> String:
	return "Pandora JSON"


func get_backend_description() -> String:
	return "Stores data via json at the data_directory provided."


func get_backend_icon() -> Texture:
	return ICON


func _init(data_dir: String):
	data_directory = data_dir


func store_all_data(data: Dictionary, context_id: String) -> Dictionary:
	var file_path = _get_file_path(context_id)
	var file: FileAccess
	if _should_use_compression():
		file = FileAccess.open_compressed(file_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
	else:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return data


func get_all_data(context_id: String) -> Dictionary:
	var file_path = _get_file_path(context_id)
	var file: FileAccess
	if _should_use_compression():
		file = FileAccess.open_compressed(file_path, FileAccess.READ)
	else:
		file = FileAccess.open(file_path, FileAccess.READ)
	var json: JSON = JSON.new()
	if file != null:
		var text = file.get_as_text()
		json.parse(text)
		file.close()
		# Backwards compatibility for already compressed files
		if json.get_data() == null and OS.is_debug_build():
			print("Compressed file detected in debug mode, decompressing...")
			return get_decompressed_data(file_path)
		return json.get_data() as Dictionary
	else:
		return {}


func get_decompressed_data(file_path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open_compressed(file_path, FileAccess.READ)
	if file != null:
		var text = file.get_as_text()
		file.close()
		var json: JSON = JSON.new()
		json.parse(text)
		return json.get_data() as Dictionary
	else:
		return {}


func load_from_file(file_path: String) -> Dictionary:
	var file: FileAccess
	if _should_use_compression():
		file = FileAccess.open_compressed(file_path, FileAccess.READ)
	else:
		file = FileAccess.open(file_path, FileAccess.READ)
	if FileAccess.file_exists(file_path) and file != null:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		json.parse(content)
		return json.get_data()
	else:
		return {}


func _get_directory_path(context_id: String) -> String:
	var directory_path = ""
	if data_directory.ends_with("//"):
		directory_path = (
			"%s%s" % [data_directory, context_id] if context_id != "" else data_directory
		)
	else:
		directory_path = (
			"%s/%s" % [data_directory, context_id] if context_id != "" else data_directory
		)
	if not DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_recursive_absolute(directory_path)
	return "%s" % [directory_path]


func _get_file_path(context_id: String) -> String:
	return "%s/data.pandora" % [_get_directory_path(context_id)]


func _should_use_compression() -> bool:
	# Ensure within the Godot Engine editor Pandora remains uncompressed
	return not Engine.is_editor_hint() and not OS.is_debug_build()
