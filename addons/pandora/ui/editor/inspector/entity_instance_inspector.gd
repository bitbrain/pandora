extends EditorInspectorPlugin

const BrowserProperty = preload("res://addons/pandora/ui/editor/inspector/entity_instance_browser_property.gd")


func _can_handle(object):
	return object != null


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object != null && type == TYPE_OBJECT:
		if hint_string == "PandoraEntity":
			var inspector_property := BrowserProperty.new(hint_string)
			add_property_editor(name, inspector_property)
			return true
		return false
	return false
