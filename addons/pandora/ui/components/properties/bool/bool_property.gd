@tool
extends PandoraPropertyControl


@onready var check_button: CheckButton = $CheckButton


func _ready() -> void:
	check_button.set_pressed(_property.get_default_value() as bool)
	check_button.toggled.connect(func(toggled:bool): _property.set_default_value(toggled))
