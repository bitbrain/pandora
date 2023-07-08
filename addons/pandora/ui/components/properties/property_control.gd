@tool
class_name PandoraPropertyControl extends MarginContainer


@export var type:String

var _property:PandoraProperty


func init(property:PandoraProperty) -> void:
	self._property = property
