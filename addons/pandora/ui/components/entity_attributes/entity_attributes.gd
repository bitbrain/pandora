@tool
extends VBoxContainer

@onready var texture_picker = %TexturePicker
@onready var script_picker = %ScriptPicker
@onready var id_generation_enabled = %IdGenerationEnabled
@onready var class_name_edit = %ClassNameEdit
@onready var color_picker = %ColorPicker

@onready var script_attribute = $ScriptAttribute
@onready var h_separator_2 = $HSeparator2
@onready var id_generation_attribute = $IdGenerationAttribute
@onready var id_class_name_attribute = %IdClassNameAttribute

var _entity: PandoraEntity


func init(entity: PandoraEntity) -> void:
	self._entity = entity
	texture_picker.set_texture_path(entity.get_icon_path())
	script_picker.set_script_path(entity.get_script_path())
	color_picker.set_color(entity.get_icon_color())
	# ensure selected script extends PandoraEntity!
	script_picker.set_filter(_is_entity)
	class_name_edit.text = entity.get_id_generation_class()
	id_generation_enabled.button_pressed = entity._generate_ids
	class_name_edit.editable = entity._generate_ids

	# only show script &  id generation on categories
	script_attribute.visible = entity is PandoraCategory
	h_separator_2.visible = entity is PandoraCategory
	id_generation_attribute.visible = entity is PandoraCategory
	id_class_name_attribute.visible = entity is PandoraCategory


func _ready() -> void:
	texture_picker.texture_changed.connect(_set_icon_path)
	script_picker.script_path_changed.connect(_set_script_path)
	id_generation_enabled.toggled.connect(_set_id_generation)
	class_name_edit.text_changed.connect(_set_class_name)
	color_picker.color_selected.connect(_set_icon_color)


func _set_icon_path(path: String) -> void:
	_entity.set_icon_path(path)


func _set_icon_color(color: Color) -> void:
	_entity.set_icon_color(color)


func _set_script_path(path: String) -> void:
	_entity.set_script_path(path)


func _set_id_generation(toggled: bool) -> void:
	_entity.set_generate_ids(toggled)
	class_name_edit.editable = toggled


func _set_class_name(name: String) -> void:
	_entity.set_id_generation_class(name.to_pascal_case())


func _is_entity(path: String) -> bool:
	var EntityClass = load(path)
	if not EntityClass:
		return false
	var entity = EntityClass.new("", "", "", "")
	return (entity as PandoraEntity) != null
