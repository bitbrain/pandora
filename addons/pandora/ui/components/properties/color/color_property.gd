@tool
extends PandoraPropertyControl


@onready var color_picker_button: ColorPickerButton = $ColorPickerButton


func _ready() -> void:
	refresh()
	color_picker_button.color_changed.connect(
		func(color:Color):
			_property.set_default_value(color)
			property_value_changed.emit())


func refresh() -> void:
	color_picker_button.color = _property.get_default_value() as Color
