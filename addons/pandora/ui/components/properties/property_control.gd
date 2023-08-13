@tool
class_name PandoraPropertyControl extends MarginContainer


signal property_value_changed
signal focused
signal unfocused


@export var type:String


var _property:PandoraProperty


func init(property:PandoraProperty) -> void:
	self._property = property
	
	
func refresh() -> void:
	pass


func get_default_settings() -> Dictionary:
	return {}


func _get_setting(key:String) -> Variant:
	if _property.has_setting_override(key):
		return _property.get_setting_override(key)
	else:
		return get_default_settings()[key]["value"]
