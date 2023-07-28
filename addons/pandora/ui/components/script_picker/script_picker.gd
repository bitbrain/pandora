@tool
extends HBoxContainer


signal script_path_changed(script_path:String)


@onready var line_edit = $LineEdit
@onready var button = $Button
@onready var file_dialog = $FileDialog


func set_script_path(script_path:String) -> void:
	if line_edit.text != script_path:
		line_edit.text = script_path
	
