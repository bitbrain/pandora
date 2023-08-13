@tool
extends PandoraPropertyControl

const MIN_VALUE = "Min Value"
const MAX_VALUE = "Max Value"


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	_property.setting_changed.connect(_setting_changed)
	_property.setting_cleared.connect(_setting_changed)
	refresh()
	spin_box.value_changed.connect(
		func(value:float):
			_property.set_default_value(int(value))
			property_value_changed.emit())


func refresh() -> void:
	spin_box.value = _property.get_default_value() as int
	spin_box.min_value = _get_setting(MIN_VALUE) as int
	spin_box.max_value = _get_setting(MAX_VALUE) as int

func get_default_settings() -> Dictionary:
	return {
		MIN_VALUE: {
			"type": "int",
			"value": -9999999999
		},
		MAX_VALUE: {
			"type": "int",
			"value": 9999999999
		}
	}


func _setting_changed(key:String) -> void:
	if key == MIN_VALUE || key == MAX_VALUE:
		refresh()
