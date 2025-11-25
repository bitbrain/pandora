@tool
class_name ArrayFieldSettings
extends VBoxContainer

signal updated(property_field: Dictionary)

@onready var label: Label = $Label
@onready var check_button: CheckButton = $HBoxContainer/CheckButton
@onready var option_button: OptionButton = $HBoxContainer/OptionButton

var property_field : Dictionary : set = set_property_field
var property_types_idx: Dictionary

func _ready() -> void:
	option_button.clear()
	var idx = 0
	for property_type in PandoraPropertyType.get_all_types():
		if property_type.allow_nesting():
			option_button.add_icon_item(
				load(property_type.get_type_icon_path()), property_type.get_type_name(), idx
			)
			property_types_idx[idx] = property_type.get_type_name()
			idx += 1

func set_property_field(field: Dictionary) -> void:
	property_field = field
	_update_field_settings()

func _update_field_settings() -> void:
	label.text = property_field["name"] + " Settings"
	check_button.button_pressed = property_field["enabled"]
	var idx = property_types_idx.find_key(property_field["settings"]["type"])
	option_button.select(idx)

func _on_check_button_toggled(toggled_on: bool) -> void:
	property_field["enabled"] = toggled_on
	updated.emit(property_field)

func _on_option_button_item_selected(index: int) -> void:
	property_field["settings"]["type"] = property_types_idx[index]
	updated.emit(property_field)
