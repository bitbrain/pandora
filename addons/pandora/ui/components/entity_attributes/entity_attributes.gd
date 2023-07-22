@tool
extends VBoxContainer


@onready var texture_picker = %TexturePicker


var _entity:PandoraEntity


func init(entity:PandoraEntity) -> void:
	self._entity = entity
	texture_picker.set_texture_path(entity.get_icon_path())
	
	
func _ready() -> void:
	texture_picker.texture_changed.connect(_on_texture_changed)
	
	
func _on_texture_changed(path:String) -> void:
	_entity.set_icon_path(path)
