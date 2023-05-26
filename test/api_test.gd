# GdUnit generated TestSuite
class_name ApiTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/api.gd"
const TEST_DIR = "testdata"

func before() -> void:
	Pandora.set_context_id(TEST_DIR)
	
	
func after() -> void:
	DirAccess.remove_absolute("res://" + TEST_DIR + "/data.pandora")
	DirAccess.remove_absolute("res://" + TEST_DIR)

func test_api_save_and_load_objects() -> void:
	var category = Pandora.create_category("Swords")
	var category_id = category._id
	var entity = Pandora.create_entity("Zweihander", category)
	var entity_id = entity._id
	Pandora._save_object_data()
	Pandora._clear()
	Pandora._load_object_data()
	assert_that(Pandora.get_category(category_id)).is_not_null()
	assert_that(Pandora.get_entity(entity_id)).is_not_null()


func test_api_save_and_load_instances() -> void:
	var category = Pandora.create_category("Swords")
	var entity = Pandora.create_entity("Zweihander", category)
	var entity_instance = Pandora.create_entity_instance(entity)
	var instance_id = entity_instance._id
	Pandora._save_object_data()
	Pandora._save_instance_data()
	Pandora._clear()
	Pandora._load_object_data()
	Pandora._load_instance_data()
	var instance = Pandora.get_entity_instance(instance_id)
	assert_that(instance).is_not_null()
	
