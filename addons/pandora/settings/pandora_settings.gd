@tool
class_name PandoraSettings
extends RefCounted

enum IDType {
	SEQUENTIAL,
	NANOID,
}

const CATEGORY_MAIN: StringName = "pandora"
const CATEGORY_CONFIG: StringName = CATEGORY_MAIN + "/config"

const SETTING_ID_TYPE: StringName = CATEGORY_CONFIG + "/id_type"

const DEFAULT_ID_TYPE: IDType = IDType.SEQUENTIAL


static func initialize() -> void:
	init_setting(
		SETTING_ID_TYPE,
		IDType.keys()[DEFAULT_ID_TYPE],
		TYPE_STRING,
		PROPERTY_HINT_ENUM,
		"%s,%s" % IDType.keys()
	)


static func init_setting(
	name: String,
	default: Variant,
	type := typeof(default),
	hint := PROPERTY_HINT_NONE,
	hint_string := ""
) -> void:
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


static func get_id_type() -> IDType:
	var default: StringName = IDType.keys()[DEFAULT_ID_TYPE]
	var key := ProjectSettings.get_setting(SETTING_ID_TYPE, default)
	return IDType[key]


static func set_id_type(id_type: IDType) -> void:
	ProjectSettings.set_setting(SETTING_ID_TYPE, IDType.keys()[id_type])
