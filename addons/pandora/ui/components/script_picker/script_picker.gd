@tool
extends HBoxContainer

signal script_path_changed(script_path: String)

@onready var line_edit = $LineEdit
@onready var button = $Button
@onready var file_dialog = $FileDialog

var _filter: Callable


func _ready() -> void:
	line_edit.text_submitted.connect(_path_changed)
	button.pressed.connect(file_dialog.popup)
	file_dialog.file_selected.connect(_path_changed)


func set_filter(filter: Callable) -> void:
	self._filter = filter


func set_script_path(script_path: String) -> void:
	if line_edit.text != script_path:
		line_edit.text = script_path


func _path_changed(new_path: String) -> void:
	if new_path.begins_with("res://"):
		if _filter == null or _filter.call(new_path):
			set_script_path(new_path)
			script_path_changed.emit(new_path)
