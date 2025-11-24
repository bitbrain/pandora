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

static var extensions_models: Dictionary[String, RefCounted] = {}
static var extensions_types: Dictionary[String, String] = {}
static var extensions_configurations: Array[Dictionary] = []
static var extensions_confs_map: Dictionary[String, int] = {}

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
	_load_all_extensions_configuration()
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

static func get_extensions_configurations() -> Array[Dictionary]:
	return extensions_configurations

static func get_extensions_confs_map() -> Dictionary:
	return extensions_confs_map

static func set_extensions_dir(array: Array) -> void:
	ProjectSettings.set_setting(SETTINGS_PANDORA_EXTENSIONS_DIR, array)
	_load_all_extensions_configuration()
	_check_new_extensions_models()

static func find_extension_configuration_property(type: String) -> Dictionary:
	for conf in extensions_configurations:
		for property in conf["properties"]:
			if property and property.has("dir_name") and property["dir_name"] == type:
				return property
	return {}

static func _load_all_extensions_configuration() -> void:
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	for extensions_dir in extensions_dirs:
		var configuration_file = FileAccess.open(extensions_dir + "/configuration.json", FileAccess.READ)
		if not configuration_file:
			push_error("Impossible to load the configuration from " + extensions_dir)
		else:
			var configuration_dic = JSON.parse_string(configuration_file.get_as_text())
			if not extensions_configurations.has(configuration_dic):
				extensions_configurations.append(configuration_dic)
				extensions_confs_map[extensions_dir] = extensions_configurations.size() - 1

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

static func save_extensions_configurations() -> void:
	var extensions_dirs = PandoraSettings.get_extensions_dirs()
	var extensions_confs_map = PandoraSettings.get_extensions_confs_map()
	var extensions_configurations = PandoraSettings.get_extensions_configurations()
	for extensions_dir in extensions_dirs:
		var configuration_file = FileAccess.open(extensions_dir + "/configuration.json", FileAccess.WRITE)
		var extensions_confs_idx: int = extensions_confs_map[extensions_dir] as int
		var extensions_configuration = extensions_configurations[extensions_confs_idx]
		configuration_file.store_string(JSON.stringify(extensions_configuration, "\t"))
		configuration_file.close()

static func get_property_dependencies_by(current_property: Dictionary) -> Array[Dictionary]:
	var extensions_configurations = PandoraSettings.get_extensions_configurations()
	var property_dependencies : Array[Dictionary] = []
	var current_dependencies := current_property["dependencies"] as Array
	var current_prop_dependencies = current_dependencies.filter(func(dep: Dictionary): return dep["type"] == "PROPERTY")
	for current_dependency in current_prop_dependencies:
		for ext_configuration in extensions_configurations:
			var ext_conf_properties := ext_configuration["properties"] as Array
			var property_dependency := ext_conf_properties.filter(func(p: Dictionary): return p["name"] == current_dependency["name"])
			if property_dependency:
				property_dependencies.append(property_dependency[0])
	return property_dependencies

static func get_lookup_property_name(value) -> String:
	for emodel in extensions_models:
		if not value is Dictionary and not value is Color:
			if typeof(value) == typeof(extensions_models[emodel]):
				return emodel
	return ""
