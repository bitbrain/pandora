@tool
extends PandoraPropertyControl


const FloatType = preload("res://addons/pandora/model/types/float.gd")


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
	refresh()
	spin_box.focus_exited.connect(func(): unfocused.emit())
	spin_box.focus_entered.connect(func(): focused.emit())
	spin_box.value_changed.connect(
		func(value:float):
			_property.set_default_value(value)
			property_value_changed.emit(value))


func refresh() -> void:
	spin_box.rounded = false
	spin_box.value = _property.get_default_value() as float
	spin_box.min_value = _property.get_setting(FloatType.SETTING_MIN_VALUE) as int
	spin_box.max_value = _property.get_setting(FloatType.SETTING_MAX_VALUE) as int
	spin_box.step = _property.get_setting(FloatType.SETTING_STEPS) as float


func _setting_changed(key:String) -> void:
	if key == FloatType.SETTING_MIN_VALUE || key == FloatType.SETTING_MAX_VALUE || key == FloatType.SETTING_STEPS:
		refresh()
