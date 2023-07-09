@tool
extends PandoraPropertyControl


@onready var color_picker_button: ColorPickerButton = $ColorPickerButton


func _ready() -> void:
	color_picker_button.color = _property.get_default_value(_entity) as Color
	color_picker_button.color_changed.connect(func(color:Color): _property.set_default_value(_entity, color))
