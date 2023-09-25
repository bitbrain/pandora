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
