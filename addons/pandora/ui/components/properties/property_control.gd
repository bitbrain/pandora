@tool
class_name PandoraPropertyControl extends MarginContainer

signal property_value_changed(value: Variant)
signal focused
signal unfocused

@export var type: String

var _property: PandoraProperty
var _fields_settings: Array = []

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		var ext_conf_property := PandoraSettings.find_extension_configuration_property(type)
		if ext_conf_property.has("enabled") and not ext_conf_property["enabled"]:
			push_error("You are trying to instantiate/add a scene that is part of a property disabled by Pandora's configurations. Are you sure you want to continue?")

func init(property: PandoraProperty) -> void:
	self._property = property
	print("init ", property)
	_load_fields_settings()

func refresh() -> void:
	pass

func update_field_settings(field_settings: Dictionary) -> void:
	_load_fields_settings()
	var fs_idx := _fields_settings.find(func(fs: Dictionary): return fs["name"] == field_settings["name"])
	_fields_settings[fs_idx] = field_settings
	Pandora.update_fields_settings.emit(type)

func _load_fields_settings() -> void:
	if _fields_settings.is_empty():
		var extension_configuration := PandoraSettings.find_extension_configuration_property(type)
		if not extension_configuration.is_empty():
			_fields_settings = extension_configuration["fields"] as Array
