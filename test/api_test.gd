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
	var item_backend = Pandora.get_item_backend()
	var category = item_backend.create_category("Swords")
	var category_id = category._id
	var entity = item_backend.create_entity("Zweihander", category)
	var entity_id = entity._id
	Pandora._save_object_data()
	Pandora._clear()
	Pandora._load_object_data()
	assert_that(item_backend.get_category(category_id)).is_not_null()
	assert_that(item_backend.get_entity(entity_id)).is_not_null()


func test_api_save_and_load_instances() -> void:
	var item_backend = Pandora.get_item_backend()
	var category = item_backend.create_category("Swords")
	var category_id = category._id
	var entity = item_backend.create_entity("Zweihander", category)
	
