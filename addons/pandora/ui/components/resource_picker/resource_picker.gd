@tool
extends HBoxContainer

signal resource_changed(resource_path: String)

@onready var line_edit = $LineEdit
@onready var load_file_button = $LoadFileButton
@onready var file_dialog: FileDialog = $FileDialog

var resource_path: String


func _ready() -> void:
	line_edit.text_submitted.connect(_path_changed)
	load_file_button.pressed.connect(file_dialog.popup)
	file_dialog.file_selected.connect(_path_changed)


func set_resource_path(path: String) -> void:
	var resource = load(path) as Resource
	if resource != null:
		line_edit.text = path
		self.resource_path = path


func _path_changed(new_path: String) -> void:
	if new_path.begins_with("res://"):
		var resource = load(new_path) as Resource
		if resource != null and resource_path != new_path:
			resource_path = new_path
			resource_changed.emit(new_path)
		else:
			line_edit.text = resource_path


func _can_drop_data(_pos, data):
	if data.type == "files":
		return true
	return false


func _drop_data(_pos, data):
	if data.type == "files":
		var path = data.files[0]
		_path_changed(path)
