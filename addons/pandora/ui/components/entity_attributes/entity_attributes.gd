@tool
extends VBoxContainer


@onready var texture_picker = %TexturePicker
@onready var script_picker = %ScriptPicker


var _entity:PandoraEntity


func init(entity:PandoraEntity) -> void:
	self._entity = entity
	texture_picker.set_texture_path(entity.get_icon_path())
	script_picker.set_script_path(entity.get_script_path())
	
	
func _ready() -> void:
	texture_picker.texture_changed.connect(_set_icon_path)
	script_picker.script_path_changed.connect(_set_script_path)
	
	
func _set_icon_path(path:String) -> void:
	_entity.set_icon_path(path)
	
	
func _set_script_path(path:String) -> void:
	_entity.set_script_path(path)
