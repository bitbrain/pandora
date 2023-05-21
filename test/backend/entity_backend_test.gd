# GdUnit generated TestSuite
class_name EntityBackendTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/entity_backend.gd"


func create_object() -> PandoraEntityBackend:
	return PandoraEntityBackend.new()


func test_create_entity() -> void:
	var backend = create_object()
	var category = backend.create_category("a")
	var entity = backend.create_entity("Test", category)
	assert_that(entity._id).is_not_null()
	assert_that(category._children).is_equal([entity])
	

func test_create_category() -> void:
	var backend = create_object()
	var category = backend.create_category("Test")
	assert_that(category._id).is_not_null()
	
	
func test_create_property_after_entity_creation() -> void:
	var backend = create_object()
	var category = backend.create_category("a")
	backend.create_property(category, "key1", "foobar1")
	var entity = backend.create_entity("Test", category)
	backend.create_property(category, "key2", "foobar2")
	var entity_instance = backend.create_entity_instance(entity)
	assert_that(entity_instance.get_string("key1")).is_equal("foobar1")
	assert_that(entity_instance.get_string("key2")).is_equal("foobar2")


func test_save_and_load_data() -> void:
	var backend = create_object()
	var old_entities = backend._entities
	var old_categories = backend._categories
	var category_a = backend.create_category("a")
	var category_b = backend.create_category("b")
	backend.create_entity("a", category_a)
	backend.create_entity("b", category_b)
	var data = backend.save_data()
	assert_that(data._categories).is_not_null()
	assert_that(data._entities).is_not_null()
	
	backend.load_data(data)
	
	assert_that(old_entities).is_equal(backend._entities)
	assert_that(old_categories).is_equal(backend._categories)
