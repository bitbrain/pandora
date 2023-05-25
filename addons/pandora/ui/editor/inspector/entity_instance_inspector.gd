extends EditorInspectorPlugin

const BrowserProperty = preload("res://addons/pandora/ui/editor/inspector/entity_instance_browser_property.tscn")


func _can_handle(object):
	return object != null


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object != null && type == TYPE_OBJECT:
		if hint_string == "PandoraEntityInstance":
			var inspector_property: = BrowserProperty.instantiate()
			add_property_editor(name, inspector_property)
			return true
		return false
	return false
