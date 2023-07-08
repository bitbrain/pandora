# GdUnit generated TestSuite
class_name EntityBackendTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/backend/entity_backend.gd"


func create_object_backend() -> PandoraEntityBackend:
	return PandoraEntityBackend.new()
	
	
func create_instance_backend() -> PandoraEntityInstanceBackend:
	return PandoraEntityInstanceBackend.new()


func test_create_entity() -> void:
	var backend = create_object_backend()
	var category = backend.create_category("a")
	var entity = backend.create_entity("Test", category)
	assert_that(entity._id).is_not_null()
	assert_that(category._children).is_equal([entity])
	

func test_create_category() -> void:
	var backend = create_object_backend()
	var category = backend.create_category("Test")
	assert_that(category._id).is_not_null()
	
	
func test_delete_entity_instance() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("a")
	var entity = backend.create_entity("Test", category)
	var instance = instance_backend.create_entity_instance(entity)
	instance_backend.delete_entity_instance(instance.get_entity_instance_id())
	assert_that(instance_backend.get_entity_instance(instance.get_entity_instance_id())).is_null()
	
	
func test_create_property_after_entity_creation() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("a")
	backend.create_property(category, "key1", "string", "foobar1")
	var entity = backend.create_entity("Test", category)
	backend.create_property(category, "key2", "string", "foobar2")
	var entity_instance = instance_backend.create_entity_instance(entity)
	assert_that(entity_instance.get_string("key1")).is_equal("foobar1")
	assert_that(entity_instance.get_string("key2")).is_equal("foobar2")
	
	
func test_entity_inherits_properties_from_category_hierarchy() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category_parent = backend.create_category("parent-category")
	var parent_entity = backend.create_entity("parent_entity", category_parent)
	var category_child = backend.create_category("child-category", category_parent)
	var child_entity = backend.create_entity("child_entity", category_child)
	backend.create_property(category_parent, "key1", "string", "foobar1")
	backend.create_property(category_child, "key2", "string", "foobar2")
	var parent_instance = instance_backend.create_entity_instance(parent_entity)
	var child_instance = instance_backend.create_entity_instance(child_entity)
	assert_that(parent_instance.get_string("key1")).is_equal("foobar1")
	assert_that(child_instance.get_string("key1")).is_equal("foobar1")
	assert_that(parent_instance.get_string("key2")).is_equal("")
	assert_that(child_instance.get_string("key2")).is_equal("foobar2")
	
	
func test_entity_instance_data_type_lookup_bool() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "bool", true)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_bool("some-property")).is_equal(true)
	
	
func test_entity_instance_data_type_lookup_int() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "int", 42)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_integer("some-property")).is_equal(42)
	
	
func test_entity_instance_data_type_lookup_float() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "float", 42.0)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_float("some-property")).is_equal(42.0)


func test_entity_instance_data_type_lookup_color() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "color", Color.RED)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_color("some-property")).is_equal(Color.RED)

func test_save_and_load_data() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var old_entities = backend._entities
	var old_categories = backend._categories
	var category_a = backend.create_category("a")
	var category_b = backend.create_category("b")
	var category_c = backend.create_category("c", category_b)
	backend.create_entity("a", category_a)
	backend.create_entity("b", category_b)
	var property = backend.create_property(category_c, "property1", "string", "Hello World")
	var data = backend.save_data()
	assert_that(data._categories).is_not_null()
	assert_that(data._entities).is_not_null()
	
	backend.load_data(data)
	
	assert_that(old_entities).is_equal(backend._entities)
	assert_that(old_categories).is_equal(backend._categories)
