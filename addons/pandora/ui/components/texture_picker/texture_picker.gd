@tool
extends HBoxContainer


signal texture_changed(texture_path:String)


@onready var texture_rect = $TextureRect
@onready var line_edit = $LineEdit


var texture_path:String


func _ready() -> void:
	line_edit.text_submitted.connect(_path_changed)
	
	
func set_texture_path(path:String) -> void:
	var resource = load(path) as Texture2D
	if resource != null:
		texture_rect.texture = resource
		line_edit.text = path
		self.texture_path = path
	
	
func _path_changed(new_path:String) -> void:
	if new_path.begins_with("res://"):
		var resource = load(new_path) as Texture2D
		if resource != null and texture_path != new_path:
			texture_path = new_path
			texture_rect.texture = resource
			texture_changed.emit(new_path)
