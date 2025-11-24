@tool
class_name ReferenceFieldSettings
extends VBoxContainer

signal updated(property_field: Dictionary)

@onready var label: Label = $Label
@onready var check_button: CheckButton = $HBoxContainer/CheckButton
@onready var category_only: CheckButton = $HBoxContainer/CategoryOnly
@onready var entity_picker: HBoxContainer = $HBoxContainer/EntityPicker

var property_field : Dictionary : set = set_property_field

func set_property_field(field: Dictionary) -> void:
	property_field = field
	_update_field_settings()

func _update_field_settings() -> void:
	label.text = property_field["name"] + " Settings"
	check_button.button_pressed = property_field["enabled"]
	category_only.button_pressed = property_field["settings"]["category_only"]
	entity_picker.categories_only = property_field["settings"]["category_only"]
	_pick_entity_or_category.call_deferred(property_field["settings"]["entity_id"])

func _pick_entity_or_category(category_id: String) -> void:
	var category = Pandora.get_category(category_id)
	entity_picker.select(category)

func _on_check_button_toggled(toggled_on: bool) -> void:
	property_field["enabled"] = toggled_on
	updated.emit(property_field)

func _on_category_only_toggled(toggled_on: bool) -> void:
	property_field["settings"]["category_only"] = toggled_on
	entity_picker.categories_only = toggled_on
	updated.emit(property_field)

func _on_entity_picker_entity_selected(entity: PandoraEntity) -> void:
	property_field["settings"]["entity_id"] = entity.get_entity_id()
