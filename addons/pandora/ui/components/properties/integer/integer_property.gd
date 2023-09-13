@tool
extends PandoraPropertyControl


const IntType = preload("res://addons/pandora/model/types/int.gd")


@onready var spin_box: SpinBox = $SpinBox


func _ready() -> void:
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
	refresh()
	spin_box.focus_entered.connect(func(): focused.emit())
	spin_box.focus_exited.connect(func(): unfocused.emit())
	spin_box.value_changed.connect(
		func(value:float):
			_property.set_default_value(int(value))
			property_value_changed.emit(value))


func refresh() -> void:
	if _property != null:
		spin_box.value = _property.get_default_value() as int
	spin_box.min_value = _property.get_setting(IntType.SETTING_MIN_VALUE) as int
	spin_box.max_value = _property.get_setting(IntType.SETTING_MAX_VALUE) as int


func _setting_changed(key:String) -> void:
	if key == IntType.SETTING_MIN_VALUE || key == IntType.SETTING_MAX_VALUE:
		refresh()
