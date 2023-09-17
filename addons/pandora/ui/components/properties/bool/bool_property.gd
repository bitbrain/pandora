@tool
extends PandoraPropertyControl


@onready var check_button: CheckButton = $CheckButton


func _ready() -> void:
	refresh()
	check_button.focus_exited.connect(func(): unfocused.emit())
	check_button.focus_entered.connect(func(): focused.emit())
	check_button.toggled.connect(
		func(toggled:bool):
			_property.set_default_value(toggled)
			property_value_changed.emit(toggled))


func refresh() -> void:
	check_button.set_pressed(_property.get_default_value() as bool)
