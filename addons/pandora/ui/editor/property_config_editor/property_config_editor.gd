@tool
extends VBoxContainer


@onready var info_label = $InfoLabel


var _property:PandoraProperty
var _default_settings:Dictionary


func set_property(property:PandoraProperty, default_settings:Dictionary) -> void:
	self._property = property
	self._default_settings = default_settings
	info_label.visible = property == null or not property.is_original()
