@tool
extends PanelContainer


var _property:PandoraProperty:
	set(p):
		_property = p
		_refresh_key.call_deferred()
var _control:PandoraPropertyControl:
	set(c):
		_control = c
		_refresh_value.call_deferred()


@onready var property_key: Label = %PropertyKey
@onready var property_value: MarginContainer = %PropertyValue


func init(property:PandoraProperty, control:PandoraPropertyControl) -> void:
	self._property = property
	self._control = control


func _refresh_key() -> void:
	property_key.text = _property.get_property_name()


func _refresh_value() -> void:
	property_value.get_children().clear()
	property_value.add_child(_control)
