@tool
class_name RangeFieldSettings
extends VBoxContainer

signal updated(property_field: Dictionary)

@onready var label: Label = $Label
@onready var check_button: CheckButton = $HBoxContainer/CheckButton
@onready var spin_box: SpinBox = $HBoxContainer/SpinBox
@onready var spin_box_2: SpinBox = $HBoxContainer/SpinBox2

var property_field : Dictionary : set = set_property_field

func set_property_field(field: Dictionary) -> void:
	property_field = field
	_update_field_settings()

func _update_field_settings() -> void:
	label.text = property_field["name"] + " Settings"
	check_button.button_pressed = property_field["enabled"]
	spin_box_2.value = property_field["settings"]["max_value"]
	spin_box_2.max_value = property_field["settings"]["max_value"]
	spin_box_2.min_value = property_field["settings"]["min_value"]
	spin_box.value = property_field["settings"]["min_value"]
	spin_box.min_value = property_field["settings"]["min_value"]
	spin_box.max_value = property_field["settings"]["max_value"]

func _on_check_button_toggled(toggled_on: bool) -> void:
	property_field["enabled"] = toggled_on
	updated.emit(property_field)

func _on_spin_box_value_changed(value: float) -> void:
	property_field["settings"]["min_value"] = value
	updated.emit(property_field)

func _on_spin_box_2_value_changed(value: float) -> void:
	property_field["settings"]["max_value"] = value
	updated.emit(property_field)
