@tool
extends HBoxContainer

@onready var edit_button: Button = $EditArrayButton
@onready var array_window: Window = $ArrayWindow

var _property: PandoraProperty

func _ready():
	edit_button.pressed.connect(func(): array_window.open(_property))

func set_property(property: PandoraProperty):
	_property = property
