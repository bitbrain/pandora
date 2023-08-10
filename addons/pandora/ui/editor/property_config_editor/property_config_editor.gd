@tool
extends VBoxContainer


@onready var info_label = $InfoLabel


var _property:PandoraProperty


func set_property(property:PandoraProperty) -> void:
	self._property = property
	info_label.visible = property == null or not property.is_original()
