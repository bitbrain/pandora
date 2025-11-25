@tool
class_name OptionsFieldSettings
extends VBoxContainer

signal updated(property_field: Dictionary)

@onready var label: Label = $Label
@onready var check_button: CheckButton = $HBoxContainer/CheckButton
@onready var edit_button: Button = $HBoxContainer/Button
@onready var options_window: Window = $OptionsWindow
@onready var line_edit: LineEdit = $HBoxContainer/LineEdit

var property_field : Dictionary : set = set_property_field

func _ready() -> void:
	edit_button.pressed.connect(func(): options_window.open(property_field["settings"]["options"] as Array))
	
	options_window.item_added.connect(func(item: Variant): 
		property_field["settings"]["options"].append(item)
		_update_field_settings.call_deferred()
		updated.emit(property_field)
	)
	options_window.item_removed.connect(func(item: Variant): 
		property_field["settings"]["options"].erase(item)
		_update_field_settings.call_deferred()
		updated.emit(property_field)
	)
	options_window.item_updated.connect(func(idx: int, item: Variant):
		property_field["settings"]["options"][idx] = item
		_update_field_settings.call_deferred()
		updated.emit(property_field)
	)

func set_property_field(field: Dictionary) -> void:
	property_field = field
	_update_field_settings()

func _update_field_settings() -> void:
	label.text = property_field["name"] + " Settings"
	check_button.button_pressed = property_field["enabled"]
	line_edit.text = str(property_field["settings"]["options"].size()) + " Options"

func _on_check_button_toggled(toggled_on: bool) -> void:
	property_field["enabled"] = toggled_on
	updated.emit(property_field)

func _on_window_close_requested() -> void:
	options_window.hide()
