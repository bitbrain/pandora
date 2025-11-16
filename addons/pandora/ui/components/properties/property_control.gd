@tool
class_name PandoraPropertyControl extends MarginContainer

signal property_value_changed(value: Variant)
signal focused
signal unfocused

@export var type: String

var _property: PandoraProperty

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		var ext_conf_property := PandoraSettings.find_extension_configuration_property(type)
		if ext_conf_property.has("enabled") and not ext_conf_property["enabled"]:
			push_error("You are trying to instantiate/add a scene that is part of a property disabled by Pandora's configurations. Are you sure you want to continue?")

func init(property: PandoraProperty) -> void:
	self._property = property


func refresh() -> void:
	pass
