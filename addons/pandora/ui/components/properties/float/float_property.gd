@tool
extends PandoraPropertyControl


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	refresh()
	spin_box.value_changed.connect(
		func(value:float):
			_property.set_default_value(value)
			property_value_changed.emit())


func refresh() -> void:
	spin_box.value = _property.get_default_value() as float


func get_default_settings() -> Dictionary:
	return {
		"Steps": {
			"type": "int",
			"value": 2
		},
		"Min": {
			"type": "int",
			"value": -9999999999
		},
		"Max": {
			"type": "int",
			"value": 9999999999
		}
	}
