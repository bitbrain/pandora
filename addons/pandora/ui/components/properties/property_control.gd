@tool
class_name PandoraPropertyControl extends MarginContainer


@export var type:String


var _property:PandoraProperty
var _entity:PandoraEntity


func init(property:PandoraProperty, entity:PandoraEntity) -> void:
	self._property = property
	self._entity = entity
