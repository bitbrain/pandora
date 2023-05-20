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


func store_all_data(data:Dictionary, context_id: String) -> Dictionary:
	var file_path = _get_file_path(context_id)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	var json = JSON.new()
	file.store_string(json.stringify(data))
	file.close()
	return data


func get_all_data(context_id: String) -> Dictionary:
	var file_path = _get_file_path(context_id)
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.get_data() as Dictionary


func _get_directory_path(context_id: String) -> String:
	var directory_path = "%s/%s" % [data_directory, context_id] if context_id != "" else data_directory
	if not DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_recursive_absolute(directory_path)
	return "%s" % [directory_path]


func _get_file_path(context_id: String) -> String:
	return "%s/data.pandora" % [_get_directory_path(context_id)]


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
