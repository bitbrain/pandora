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

const SETTING_PANDORA_DATA_PATH: StringName = CATEGORY_CONFIG + "/data_path"
const DEFAULT_PANDORA_DATA_PATH: StringName = "res://data.pandora"

const SETTINGS_PANDORA_DEFINITIONS_DIR: StringName = CATEGORY_CONFIG + "/definitions_dir"
const DEFAULT_PANDORA_DEFINITIONS_DIR: StringName = "res://pandora/"


static func initialize() -> void:
    init_setting(
        SETTING_ID_TYPE,
        IDType.keys()[DEFAULT_ID_TYPE],
        TYPE_STRING,
        PROPERTY_HINT_ENUM,
        "%s,%s" % IDType.keys()
    )

    init_setting(
        SETTING_PANDORA_DATA_PATH,
        DEFAULT_PANDORA_DATA_PATH,
        TYPE_STRING,
        PROPERTY_HINT_FILE,
    )

    init_setting(
        SETTINGS_PANDORA_DEFINITIONS_DIR,
        DEFAULT_PANDORA_DEFINITIONS_DIR,
        TYPE_STRING,
        PROPERTY_HINT_DIR
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


static func get_data_path() -> StringName:
    return ProjectSettings.get_setting(
        SETTING_PANDORA_DATA_PATH,
        DEFAULT_PANDORA_DATA_PATH
    )


static func set_data_path(path: StringName) -> void:
    ProjectSettings.set_setting(SETTING_PANDORA_DATA_PATH, path)


static func get_definitions_dir() -> StringName:
    return ProjectSettings.get_setting(
        SETTINGS_PANDORA_DEFINITIONS_DIR,
        DEFAULT_PANDORA_DEFINITIONS_DIR
    )


static func set_definitions_dir(path: StringName) -> void:
    ProjectSettings.set_setting(SETTINGS_PANDORA_DEFINITIONS_DIR, path)
