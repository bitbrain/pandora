@tool
extends PandoraPropertyControl


@onready var line_edit: LineEdit = $LineEdit


func _ready() -> void:
	line_edit.text = _property.get_default_value(_entity) as String
	line_edit.text_changed.connect(func(text:String): _property.set_default_value(_entity, text))
