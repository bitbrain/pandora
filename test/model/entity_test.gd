# GdUnit generated TestSuite
class_name EntityTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/model/entity.gd"


func test_init_entity() -> void:
	var entity = PandoraEntity.new()
	entity.init_entity("123", "Test Entity", "res://hello.jpg", "123")
	assert_that(entity.get_entity_id()).is_equal("123")


func test_instantiate_entity() -> void:
	var entity = PandoraEntity.new()
	entity.init_entity("123", "Test Entity", "res://hello.jpg", "123")
	var instance = entity.instantiate()
	assert_that(instance.get_entity_id()).is_equal("123")
	assert_bool(instance.is_instance()).is_true()


func test_duplicate_entity() -> void:
	var entity = PandoraEntity.new()
	entity.init_entity("123", "Test Entity", "res://hello.jpg", "123")
	var instance = entity.duplicate_instance()
	assert_that(instance.get_entity_id()).is_equal("123")
	assert_bool(instance.is_instance()).is_true()


func test_entity_set_get_vector2_property() -> void:
	var category = Pandora.create_category("Test")
	var entity = Pandora.create_entity("Test Entity", category) as PandoraEntity
	var vector2_property = Pandora.create_property(category, "Vector2 Test", "vector2")
	vector2_property.set_default_value(Vector2.ONE)
	assert_that(entity.get_vector2("Vector2 Test")).is_equal(Vector2.ONE)


func test_entity_set_get_vector2i_property() -> void:
	var category = Pandora.create_category("Test")
	var entity = Pandora.create_entity("Test Entity", category) as PandoraEntity
	var vector2_property = Pandora.create_property(category, "Vector2i Test", "vector2i")
	vector2_property.set_default_value(Vector2i.ONE)
	assert_that(entity.get_vector2i("Vector2i Test")).is_equal(Vector2i.ONE)


func test_entity_set_get_vector3_property() -> void:
	var category = Pandora.create_category("Test")
	var entity = Pandora.create_entity("Test Entity", category) as PandoraEntity
	var vector2_property = Pandora.create_property(category, "Vector3 Test", "vector3")
	vector2_property.set_default_value(Vector3.ONE)
	assert_that(entity.get_vector3("Vector3 Test")).is_equal(Vector3.ONE)


func test_entity_set_get_vector3i_property() -> void:
	var category = Pandora.create_category("Test")
	var entity = Pandora.create_entity("Test Entity", category) as PandoraEntity
	var vector2_property = Pandora.create_property(category, "Vector3i Test", "vector3i")
	vector2_property.set_default_value(Vector3i.ONE)
	assert_that(entity.get_vector3i("Vector3i Test")).is_equal(Vector3i.ONE)
