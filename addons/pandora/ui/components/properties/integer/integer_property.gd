@tool
extends PandoraPropertyControl


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	refresh()
	spin_box.value_changed.connect(
		func(value:float):
			_property.set_default_value(int(value))
			property_value_changed.emit())


func refresh() -> void:
	spin_box.value = _property.get_default_value() as int
