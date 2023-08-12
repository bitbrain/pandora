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
	if _property != null:
		var value = _property.get_default_value() as String
		if value != line_edit.text:
			line_edit.text = value


func get_default_settings() -> Dictionary:
	return {
		"Min length": -1,
		"Max Length": -1,
	}
