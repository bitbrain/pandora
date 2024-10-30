extends EditorInspectorPlugin

const EntityBrowserProperty = preload("./entity_instance_browser_property.gd")
const CategoryBrowserProperty = preload("./entity_category_browser_property.gd")

const PANDORA_ENTITY_CLASS = &"PandoraEntity"
const PANDORA_CATEGORY_CLASS = &"PandoraCategory"

# ClassName -> Dictionary
var _global_class_cache = {}


func _can_handle(object):
	return object != null


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if _global_class_cache.is_empty():
		for global_class in ProjectSettings.get_global_class_list():
			_global_class_cache[global_class["class"]] = global_class
	if type == TYPE_OBJECT:
		if _is_pandora_category(hint_string):
			var inspector_property := CategoryBrowserProperty.new(_global_class_cache[hint_string])
			add_property_editor(name, inspector_property)
			return true
		elif _is_pandora_entity(hint_string):
			var inspector_property := EntityBrowserProperty.new(_global_class_cache[hint_string])
			add_property_editor(name, inspector_property)
			return true
		return false
	return false


func _is_pandora_entity(clazz: String) -> bool:
	if clazz == PANDORA_ENTITY_CLASS:
		return true
	if clazz == "":
		return false
	var parent = _get_parent_class(clazz)
	if parent == null:
		return false
	if parent == PANDORA_ENTITY_CLASS:
		return true
	return _is_pandora_entity(parent)
	
	
func _is_pandora_category(clazz: String) -> bool:
	if clazz == PANDORA_CATEGORY_CLASS:
		return true
	if clazz == "":
		return false
	var parent = _get_parent_class(clazz)
	if parent == null:
		return false
	if parent == PANDORA_CATEGORY_CLASS:
		return true
	return _is_pandora_category(parent)


func _get_parent_class(clazz_name: String) -> String:
	if not _global_class_cache.has(clazz_name):
		return ""
	var clazz = _global_class_cache[clazz_name]
	if not _global_class_cache.has(clazz["base"]):
		return ""
	return _global_class_cache[clazz["base"]]["class"]
