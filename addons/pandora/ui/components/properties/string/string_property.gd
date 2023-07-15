@tool
extends PandoraPropertyControl


@onready var line_edit: LineEdit = $LineEdit


func _ready() -> void:
	refresh()
	line_edit.text_changed.connect(
		func(text:String):
			_property.set_default_value(text)
			property_value_changed.emit())


func refresh() -> void:
	line_edit.text = _property.get_default_value() as String
