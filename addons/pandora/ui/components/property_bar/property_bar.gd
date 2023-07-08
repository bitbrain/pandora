@tool
class_name PandoraPropertyBar extends HBoxContainer


signal property_added(scene:PackedScene)


@onready var _buttons = get_children()


func _ready() -> void:
	for button in _buttons:
		button.pressed.connect(_pressed.bind(button as PandoraPropertyButton))


func _pressed(button:PandoraPropertyButton) -> void:
	property_added.emit(button.scene)
