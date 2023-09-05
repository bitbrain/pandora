@tool
class_name PandoraSettings
extends RefCounted


enum ID_TYPE {
	Sequential,
	NanoID,
}

const CATEGORY_MAIN: StringName = "pandora"
const CATEGORY_CONFIG: StringName = CATEGORY_MAIN + "/config"

const SETTING_ID_TYPE: StringName = CATEGORY_CONFIG + "/id_type"
const DEFAULT_ID_TYPE: StringName = "sequential"
const HINT_ID_TYPE: StringName = "sequential,nanoid"


static func initialize() -> void:
	init_setting(SETTING_ID_TYPE, DEFAULT_ID_TYPE, TYPE_STRING,
			PROPERTY_HINT_ENUM, HINT_ID_TYPE)


static func init_setting(name: String, default: Variant, type := typeof(default),
		hint := PROPERTY_HINT_NONE, hint_string := "") -> void:
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, default)

	ProjectSettings.set_initial_value(name, default)

	var info = {
		"name": name,
		"type": type,
		"hint": hint,
		"hint_string": hint_string,
	}
	ProjectSettings.add_property_info(info)


static func get_id_type() -> ID_TYPE:
	var id_type := ProjectSettings.get_setting(SETTING_ID_TYPE, DEFAULT_ID_TYPE)
	
	if id_type == "sequential":
		return ID_TYPE.Sequential
	if id_type == "nanoid":
		return ID_TYPE.NanoID
	
	push_error("unknown id type: %s" % id_type)
	return ID_TYPE.Sequential
