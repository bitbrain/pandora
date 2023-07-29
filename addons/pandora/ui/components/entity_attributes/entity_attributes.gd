@tool
extends VBoxContainer


@onready var texture_picker = %TexturePicker
@onready var script_picker = %ScriptPicker
@onready var id_generation_enabled = %IdGenerationEnabled
@onready var id_generation_path_picker = %IdGenerationPathPicker

@onready var script_attribute = $ScriptAttribute
@onready var h_separator_2 = $HSeparator2
@onready var id_generation_attribute = $IdGenerationAttribute
@onready var id_generation_path_attribute = $IdGenerationPathAttribute


var _entity:PandoraEntity


func init(entity:PandoraEntity) -> void:
	self._entity = entity
	texture_picker.set_texture_path(entity.get_icon_path())
	script_picker.set_script_path(entity.get_script_path())
	
	# only show script &  id generation on categories
	script_attribute.visible = entity is PandoraCategory
	h_separator_2.visible = entity is PandoraCategory
	id_generation_attribute.visible = entity is PandoraCategory
	id_generation_path_attribute.visible = entity is PandoraCategory
	
func _ready() -> void:
	texture_picker.texture_changed.connect(_set_icon_path)
	script_picker.script_path_changed.connect(_set_script_path)
	
	
func _set_icon_path(path:String) -> void:
	_entity.set_icon_path(path)
	
	
func _set_script_path(path:String) -> void:
	_entity.set_script_path(path)
