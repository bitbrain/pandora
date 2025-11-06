# GdUnit generated TestSuite
class_name PandoraSettingsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


# TestSuite generated from
const __source = 'res://addons/pandora/settings/pandora_settings.gd'
const TEST_DIR = "testdata"

const IDType := PandoraSettings.IDType

const SETTING_ID_TYPE := PandoraSettings.SETTING_ID_TYPE
const SETTING_PANDORA_DATA_PATH := PandoraSettings.SETTING_PANDORA_DATA_PATH
const SETTINGS_PANDORA_EXTENSIONS_DIR := PandoraSettings.SETTINGS_PANDORA_EXTENSIONS_DIR

func test_initialize() -> void:
	ProjectSettings.clear(SETTING_ID_TYPE)
	PandoraSettings.initialize()
	var id_type: String = IDType.keys()[PandoraSettings.DEFAULT_ID_TYPE]
	assert_bool(ProjectSettings.has_setting(SETTING_ID_TYPE)).is_true()
	assert_str(ProjectSettings.get_setting(SETTING_ID_TYPE)).is_equal(id_type)


func test_init_setting() -> void:
	ProjectSettings.clear(SETTING_ID_TYPE)
	var id_type: String = IDType.keys()[PandoraSettings.DEFAULT_ID_TYPE]
	PandoraSettings.init_setting(SETTING_ID_TYPE, id_type,
			TYPE_STRING, PROPERTY_HINT_ENUM, "%s,%s" % IDType.keys())
	assert_bool(ProjectSettings.has_setting(SETTING_ID_TYPE)).is_true()
	assert_str(ProjectSettings.get_setting(SETTING_ID_TYPE)).is_equal(id_type)


func test_get_id_type() -> void:
	ProjectSettings.clear(SETTING_ID_TYPE)
	var id_type: String = IDType.keys()[PandoraSettings.DEFAULT_ID_TYPE]
	PandoraSettings.init_setting(SETTING_ID_TYPE, id_type,
			TYPE_STRING, PROPERTY_HINT_ENUM, "%s,%s" % IDType.keys())
	var expected: String = ProjectSettings.get_setting(SETTING_ID_TYPE, id_type)
	var actual := PandoraSettings.get_id_type()
	assert_int(actual).is_equal(IDType[expected])


func test_set_id_type() -> void:
	ProjectSettings.clear(SETTING_ID_TYPE)
	PandoraSettings.init_setting(SETTING_ID_TYPE,
			IDType.keys()[PandoraSettings.DEFAULT_ID_TYPE], TYPE_STRING,
			PROPERTY_HINT_ENUM, "%s,%s" % IDType.keys())
	PandoraSettings.set_id_type(IDType.NANOID)
	assert_int(PandoraSettings.get_id_type()).is_equal(IDType.NANOID)


func test_get_data_path() -> void:
	ProjectSettings.clear(SETTING_PANDORA_DATA_PATH)
	PandoraSettings.init_setting(
		SETTING_PANDORA_DATA_PATH, "res://data.pandora",
		TYPE_STRING, PROPERTY_HINT_FILE, "*.pandora"
	)
	var expected: String = ProjectSettings.get_setting(SETTING_PANDORA_DATA_PATH)
	var actual := PandoraSettings.get_data_path()
	assert_str(actual).is_equal(expected)


func test_set_data_path() -> void:
	ProjectSettings.clear(SETTING_PANDORA_DATA_PATH)
	PandoraSettings.init_setting(
		SETTING_PANDORA_DATA_PATH, "res://data.pandora",
		TYPE_STRING, PROPERTY_HINT_FILE, "*.pandora"
	)
	
	Pandora.set_context_id("")
	var new_path: String = "res://" + TEST_DIR + "/" + "collection.pandora"
	PandoraSettings.set_data_path(new_path)
	assert_str(PandoraSettings.get_data_path()).is_equal(new_path)

	# Reinitialize the data storage with the new path
	Pandora._storage = PandoraJsonDataStorage.new(new_path.get_base_dir())
	# Resave the data to ensure it uses the new path
	Pandora.save_data()
	# Unload and reload the data to ensure it reflects the new path
	Pandora._clear()
	Pandora.load_data()

	assert_array(Pandora.get_all_entities()).is_not_empty()

	assert_file(new_path).exists()

	# Clean up
	DirAccess.remove_absolute(new_path)

	PandoraSettings.set_data_path("res://data.pandora")
	assert_str(PandoraSettings.get_data_path()).is_equal("res://data.pandora")
	
	Pandora._storage = PandoraJsonDataStorage.new(PandoraSettings.get_data_path().get_base_dir())

	Pandora._clear()
	Pandora.load_data()

func test_get_extensions_dirs() -> void:
	ProjectSettings.clear(SETTINGS_PANDORA_EXTENSIONS_DIR)
	PandoraSettings.init_setting(
		SETTINGS_PANDORA_EXTENSIONS_DIR, ["res://pandora/extensions"],
		TYPE_ARRAY, PROPERTY_HINT_DIR, "*.pandora"
	)
	var expected: Array = ProjectSettings.get_setting(SETTINGS_PANDORA_EXTENSIONS_DIR)
	var actual: Array = PandoraSettings.get_extensions_dirs()
	assert_array(actual).is_equal(expected)
	
func test_compare_with_extensions_models() -> void:
	PandoraSettings.initialize()
	var test := PandoraTestProperty.new("apple", 2)
	var actual := PandoraSettings.compare_with_extensions_models(test)
	assert_bool(actual).is_equal(true)
