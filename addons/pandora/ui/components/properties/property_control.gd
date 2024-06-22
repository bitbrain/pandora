@tool
class_name PandoraPropertyControl extends MarginContainer

signal property_value_changed(value: Variant)
signal focused
signal unfocused

@export var type: String

var _property: PandoraProperty


func init(property: PandoraProperty) -> void:
	self._property = property


func refresh() -> void:
	pass
