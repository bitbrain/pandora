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

const SETTINGS_PANDORA_EXTENSIONS_DIR: StringName = CATEGORY_CONFIG + "/extensions"
const DEFAULT_PANDORA_EXTENSIONS_DIR: Array[StringName] = ["res://pandora/extensions"]

const SETTING_USE_CATEGORY_TABS:  StringName = CATEGORY_CONFIG + "/use_category_tabs"
const DEFAULT_USE_CATEGORY_TABS: bool = false

static var extensions_models: Dictionary[String, RefCounted] = {}
static var extensions_types: Dictionary[String, String] = {}

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
	
	init_setting(
		SETTINGS_PANDORA_EXTENSIONS_DIR,
		DEFAULT_PANDORA_EXTENSIONS_DIR,
		TYPE_ARRAY,
		PROPERTY_HINT_DIR
	)

	init_setting(
		SETTING_USE_CATEGORY_TABS,
		DEFAULT_USE_CATEGORY_TABS,
		TYPE_BOOL
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
	_check_new_extensions_models()

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

static func get_extensions_dirs() -> Array:
	return ProjectSettings.get_setting(
		SETTINGS_PANDORA_EXTENSIONS_DIR,
		DEFAULT_PANDORA_EXTENSIONS_DIR
	)

static func set_extensions_dir(array: Array) -> void:
	ProjectSettings.set_setting(SETTINGS_PANDORA_EXTENSIONS_DIR, array)
	_check_new_extensions_models()

static func get_use_category_tabs() -> bool:
	return ProjectSettings.get_setting(
		SETTING_USE_CATEGORY_TABS,
		DEFAULT_USE_CATEGORY_TABS
	)

static func set_use_category_tabs(enabled: bool) -> void:
	ProjectSettings.set_setting(SETTING_USE_CATEGORY_TABS, enabled)

static func _check_new_extensions_models() -> void:
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	for extensions_dir in extensions_dirs:
		var main_dir = DirAccess.open(extensions_dir)
		for ed_path in main_dir.get_directories():
			var extension_dir = DirAccess.open(extensions_dir + "/" + ed_path)
			assert(extension_dir.dir_exists("model"))
			var model_dir = DirAccess.open(extensions_dir + "/" + ed_path + "/model/")
			assert(model_dir.dir_exists("types"))
			for file in model_dir.get_files():
				if not file.contains("_type") and not file.ends_with(".uid"):
					var model = load(extensions_dir + "/" + ed_path + "/model/" + file)
					if not extensions_models.has(file):
						extensions_models[file] = model
			
			var types_dir = DirAccess.open(extensions_dir + "/" + ed_path + "/model/types/")
			types_dir.list_dir_begin()
			var file_name: String = types_dir.get_next()
			while file_name != "":
				if file_name.ends_with(".gd"):
					var type_name = file_name.left(file_name.length() - 3)
					extensions_types[type_name] = extensions_dir + "/" + ed_path + "/model/types/"
				file_name = types_dir.get_next()
			types_dir.list_dir_end()

static func compare_with_extensions_models(value) -> bool:
	for emodel in extensions_models:
		if not value is Dictionary and not value is Color:
			if typeof(value) == typeof(extensions_models[emodel]):
				return true
	return false

static func get_lookup_property_name(value) -> String:
	for emodel in extensions_models:
		if not value is Dictionary and not value is Color:
			if typeof(value) == typeof(extensions_models[emodel]):
				return emodel
	return ""
