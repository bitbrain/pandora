@tool
extends VBoxContainer

const EntityPicker = preload("res://addons/pandora/ui/components/entity_picker/entity_picker.tscn")

@onready var info_label = $InfoLabel
@onready var header_label = $HeaderLabel
@onready var properties_settings = $PropertiesSettings

var _property: PandoraProperty
var _default_settings: Dictionary
var property_types_idx: Dictionary


func set_property(property: PandoraProperty) -> void:
	for child in properties_settings.get_children():
		child.queue_free()
	properties_settings.get_children().clear()
	self._property = property
	if property:
		var property_type = property.get_property_type()
		if property_type.get_type_name() == "array":
			self._default_settings = property_type.get_merged_settings(property)
		else:
			self._default_settings = property_type.get_settings()
	else:
		self._default_settings = {}
	info_label.visible = property == null or not property.is_original()
	header_label.visible = not info_label.visible

	for default_setting_name in _default_settings:
		var setting = HBoxContainer.new()
		setting.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var label = Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = default_setting_name
		setting.add_child(label)
		var default_setting = _default_settings[default_setting_name]
		var current_value = (
			_property.get_setting_override(default_setting_name)
			if _property.has_setting_override(default_setting_name)
			else default_setting.value
		)
		var options: Array[Variant] = []
		options.assign(default_setting["options"] if default_setting.has("options") else [])
		var control = _new_control_for_type(
			default_setting_name,
			default_setting.type,
			options,
			default_setting.value,
			current_value
		)
		if control != null:
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			setting.add_child(control)
			properties_settings.add_child(setting)
		else:
			setting.queue_free()
			push_warning("Unsupported property setting type for " + str(default_setting_name))


func _new_control_for_type(
	key: String,
	type: String,
	options: Array[Variant],
	default_value: Variant,
	current_value: Variant
) -> Control:
	if options.size() > 0:
		var option_button = OptionButton.new()
		var popup = option_button.get_popup()
		var options_to_index = {}
		var index = 0
		for option in options:
			popup.add_radio_check_item(str(option), index)
			options_to_index[option] = index
			index = index + 1
		option_button.select(options_to_index[current_value])
		popup.index_pressed.connect(func(index): _change_value(key, options[index], default_value))
		return option_button
	elif type == "string":
		var edit = LineEdit.new()
		edit.text = current_value as String
		edit.text_changed.connect(func(new): _change_value(key, new, default_value))
		return edit
	elif type == "color":
		var color_picker = ColorPickerButton.new()
		color_picker.color = current_value as Color
		color_picker.color_changed.connect(func(new): _change_value(key, new, default_value))
		return color_picker
	elif type == "int" or type == "float":
		var spin_box = SpinBox.new()
		spin_box.min_value = -999999999
		spin_box.max_value = 999999999
		spin_box.step = 0.01 if type == "float" else 1
		spin_box.custom_arrow_step = spin_box.step
		spin_box.rounded = type == "int"
		spin_box.value = current_value
		spin_box.value_changed.connect(func(new): _change_value(key, new, default_value))
		return spin_box
	elif type == "bool":
		var check_button = CheckButton.new()
		check_button.set_pressed(current_value as bool)
		check_button.toggled.connect(func(new): _change_value(key, new, default_value))
		return check_button
	elif type == "reference":
		var entity_picker = EntityPicker.instantiate()
		entity_picker.categories_only = true
		# pre-select category deferred since
		# data may not be available right now
		if current_value != "":
			_select_category_on_picker.call_deferred(entity_picker, current_value)
		entity_picker.entity_selected.connect(
			func(new): _change_value(key, new.get_entity_id(), default_value)
		)
		return entity_picker
		# pre-select category deferred since
		# data may not be available right now
		if current_value != "":
			_select_category_on_picker.call_deferred(entity_picker, current_value)
		entity_picker.entity_selected.connect(
			func(new): _change_value(key, new.get_entity_id(), default_value)
		)
		return entity_picker
	elif type == "property_type":
		var property_type_picker: OptionButton = OptionButton.new()
		var idx = 0
		for property_type in PandoraPropertyType.get_all_types():
			if property_type.allow_nesting():
				property_type_picker.add_icon_item(
					load(property_type.get_type_icon_path()), property_type.get_type_name(), idx
				)
				property_types_idx[idx] = property_type.get_type_name()
				idx += 1
		if current_value != "":
			_select_prop_type.call_deferred(property_type_picker, current_value)
		property_type_picker.item_selected.connect(
			func(idx): _change_value(key, property_types_idx[idx], default_value)
		)
		return property_type_picker
	return null


func _change_value(key: String, new_value: Variant, default_value: Variant) -> void:
	if new_value == default_value and _property.has_setting_override(key):
		_property.clear_setting_override(key)
	elif new_value != default_value:
		_property.set_setting_override(key, new_value)
	_refresh()


func _select_category_on_picker(picker, category_id: String) -> void:
	var category = Pandora.get_category(category_id)
	picker.select(category)


func _select_prop_type(picker, prop_type: String) -> void:
	picker.select(property_types_idx.find_key(prop_type))


func _refresh():
	set_property(_property)
