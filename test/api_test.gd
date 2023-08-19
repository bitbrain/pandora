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
	Pandora.save_data()
	Pandora._clear()
	Pandora.load_data()
	assert_that(Pandora.get_category(category_id)).is_not_null()
	assert_that(Pandora.get_entity(entity_id)).is_not_null()


func _save_load_instance() -> void:
	var category = Pandora.create_category("Swords")
	var category_id = category._id
	var entity = Pandora.create_entity("Zweihander", category)
	var instance = entity.instantiate()
	var data = Pandora.serialize(instance)
	var new_instance = Pandora.deserialize(data)
	
	assert_that(instance).is_equal(new_instance)
