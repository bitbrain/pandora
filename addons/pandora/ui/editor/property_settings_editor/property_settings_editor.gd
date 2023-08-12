@tool
extends VBoxContainer


const EntityPicker = preload("res://addons/pandora/ui/components/entity_picker/entity_picker.tscn")


@onready var info_label = $InfoLabel
@onready var header_label = $HeaderLabel
@onready var properties_settings = $PropertiesSettings


var _property:PandoraProperty
var _default_settings:Dictionary



func set_property(property:PandoraProperty, default_settings:Dictionary) -> void:
	for child in properties_settings.get_children():
		child.queue_free()
	self._property = property
	self._default_settings = default_settings
	info_label.visible = property == null or not property.is_original()
	header_label.visible = not info_label.visible

	for default_setting_name in default_settings:
		var setting = HBoxContainer.new()
		setting.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label = Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = default_setting_name
		setting.add_child(label)
		var default_setting = default_settings[default_setting_name]
		var current_value = _property.get_setting_override(default_setting_name) if _property.has_setting_override(default_setting_name) else default_setting.value
		var control = _new_control_for_type(default_setting_name, default_setting.type, default_setting.value, current_value)
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		setting.add_child(control)
		properties_settings.add_child(setting)


func _new_control_for_type(key:String, type:String, default_value:Variant, current_value:Variant) -> Control:
	if type == "string":
		var edit = LineEdit.new()
		edit.text = current_value as String
		edit.text_changed.connect(func(new): _change_value(key, new, default_value))
	if type == "color":
		var color_picker = ColorPickerButton.new()
		color_picker.color = current_value as Color
		color_picker.color_changed.connect(func(new): _change_value(key, new, default_value))
		return color_picker
	if type == "int" or type == "float":
		var spin_box = SpinBox.new()
		spin_box.value = current_value as int
		spin_box.rounded = type == "int"
		spin_box.min_value = -999999999
		spin_box.max_value = 999999999
		spin_box.value_changed.connect(func(new): _change_value(key, new, default_value))
		return spin_box
	if type == "bool":
		var check_button = CheckButton.new()
		check_button.set_pressed(current_value as bool)
		check_button.toggled.connect(func(new): _change_value(key, new, default_value))
		return check_button
	if type == "reference":
		var entity_picker = EntityPicker.instantiate()
		entity_picker.categories_only = true
		# pre-select category deferred since
		# data may not be available right now
		if current_value != "":
			_select_category_on_picker.call_deferred(entity_picker, current_value)
		entity_picker.entity_selected.connect(func(new): _change_value(key, new.get_entity_id(), default_value))
		return entity_picker
	return null


func _change_value(key:String, new_value:Variant, default_value:Variant) -> void:
	if new_value == default_value and _property.has_setting_override(key):
		_property.clear_setting_override(key)
	elif new_value != default_value:
		_property.set_setting_override(key, new_value)


func _select_category_on_picker(picker, category_id:String) -> void:
	var category = Pandora.get_category(category_id)
	picker.select(category)
