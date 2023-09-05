# GdUnit generated TestSuite
class_name SequentialIdGeneratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


# TestSuite generated from
const __source = 'res://addons/pandora/util/id/sequential_id_generator.gd'


func test_generate_clear() -> void:
	var id_generator = auto_free(preload(__source).new())
	assert_that(id_generator.generate()).is_equal("1")
	assert_that(id_generator.generate()).is_equal("2")
	id_generator._context = "other-context"
	assert_that(id_generator.generate()).is_equal("1")
	assert_dict(id_generator._ids_by_context).is_not_empty()
	id_generator.clear()
	assert_dict(id_generator._ids_by_context).is_empty()


func test_save_load_data() -> void:
	var id_generator = auto_free(preload(__source).new())
	assert_that(id_generator.generate()).is_equal("1")
	id_generator._context = "other-context"
	assert_that(id_generator.generate()).is_equal("1")

	var other_id_generator = auto_free(preload(__source).new())
	other_id_generator.load_data(id_generator.save_data())
	assert_that(other_id_generator.generate()).is_equal("2")
	other_id_generator._context = "other-context"
	assert_that(other_id_generator.generate()).is_equal("2")
