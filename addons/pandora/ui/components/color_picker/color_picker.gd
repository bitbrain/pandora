@tool
extends MarginContainer

@onready var color_picker_button: ColorPickerButton = $ColorPickerButton

signal color_selected(color: Color)


func _ready():
	color_picker_button.color_changed.connect(func(color): color_selected.emit(color))


func set_color(color: Color) -> void:
	color_picker_button.color = color
