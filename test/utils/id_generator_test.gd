# GdUnit generated TestSuite
class_name IdGeneratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/util/id_generator.gd"
	

func test_generate_id() -> void:
	var id_generator = preload(__source).new()
	assert_that(id_generator.generate()).is_equal("1")
	assert_that(id_generator.generate()).is_equal("2")
	assert_that(id_generator.generate("other-context")).is_equal("1")


func test_load_save_state() -> void:
	var id_generator = preload(__source).new()
	assert_that(id_generator.generate()).is_equal("1")
	assert_that(id_generator.generate("other-context")).is_equal("1")
	
	var other_id_generator = preload(__source).new()
	other_id_generator.load_data(id_generator.save_data())
	assert_that(other_id_generator.generate()).is_equal("2")
	assert_that(other_id_generator.generate("other-context")).is_equal("2")
