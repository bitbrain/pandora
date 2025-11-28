@tool
extends PandoraPropertyControl

const TestPropertyType = preload("../model/types/test_property.gd")

@onready var text_edit: TextEdit = $HBoxContainer/TextEdit
@onready var spin_box: SpinBox = $HBoxContainer/SpinBox
var current_property : PandoraTestProperty = PandoraTestProperty.new("", 0)

func _ready() -> void:
	refresh()
	Pandora.update_fields_settings.connect(_on_update_fields_settings)
	
	if _property != null:
		_property.setting_changed.connect(_setting_changed)
		_property.setting_cleared.connect(_setting_changed)
		text_edit.focus_exited.connect(func(): unfocused.emit())
		text_edit.focus_entered.connect(func(): focused.emit())
		text_edit.text_changed.connect(
			func():
				current_property.set_item_name(text_edit.text)
				_property.set_default_value(current_property)
				property_value_changed.emit(current_property))
	
	spin_box.focus_entered.connect(func(): focused.emit())
	spin_box.focus_exited.connect(func(): unfocused.emit())
	spin_box.value_changed.connect(
		func(value: float):
			current_property.set_quantity(int(value))
			_property.set_default_value(current_property)
			property_value_changed.emit(current_property))

func refresh() -> void:
	for field_settings in _fields_settings:
		if field_settings["name"] == "Quantity":
			spin_box.visible = field_settings["enabled"]
		elif field_settings["name"] == "Item Name":
			spin_box.visible = field_settings["enabled"]
	
	if _property != null:
		if _property.get_setting(TestPropertyType.SETTING_MIN_VALUE):
			spin_box.min_value = _property.get_setting(TestPropertyType.SETTING_MIN_VALUE) as int
		if _property.get_setting(TestPropertyType.SETTING_MAX_VALUE):
			spin_box.max_value = _property.get_setting(TestPropertyType.SETTING_MAX_VALUE) as int
		if _property.get_default_value() != null:
			current_property = _property.get_default_value() as PandoraTestProperty
			text_edit.text = current_property.get_item_name()
			text_edit.set_caret_column(text_edit.text.length())
			spin_box.value = current_property.get_quantity()

func _setting_changed(key:String) -> void:
	if key == TestPropertyType.SETTING_MIN_VALUE || key == TestPropertyType.SETTING_MAX_VALUE:
		refresh()

func _on_update_fields_settings(property_type: String) -> void:
	if property_type == type:
		refresh()
