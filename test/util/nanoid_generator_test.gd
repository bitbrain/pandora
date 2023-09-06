# GdUnit generated TestSuite
class_name PandoraNanoIDGeneratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


# TestSuite generated from
const __source = 'res://addons/pandora/util/nanoid_generator.gd'


func test_generate_size() -> void:
	var id_generator = auto_free(preload(__source).new(3))
	assert_that(len(id_generator.generate())).is_equal(3)
	id_generator.size = 4
	assert_that(len(id_generator.generate())).is_equal(4)
