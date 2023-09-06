# GdUnit generated TestSuite
class_name PandoraSettingsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


# TestSuite generated from
const __source = 'res://addons/pandora/settings/pandora_settings.gd'


const IDType := PandoraSettings.IDType

const SETTING_ID_TYPE := PandoraSettings.SETTING_ID_TYPE


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
