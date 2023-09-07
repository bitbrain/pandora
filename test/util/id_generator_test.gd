# GdUnit generated TestSuite
class_name PandoraIDGeneratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')


# TestSuite generated from
const __source = 'res://addons/pandora/util/id_generator.gd'


func test_generate() -> void:
	var id_generator = auto_free(preload(__source).new())
	
	PandoraSettings.set_id_type(PandoraSettings.IDType.NANOID)
	id_generator._nanoid.default_length = 3
	assert_that(len(id_generator.generate())).is_equal(3)
	
	PandoraSettings.set_id_type(PandoraSettings.IDType.SEQUENTIAL)
	id_generator.clear()
	assert_that(id_generator.generate()).is_equal("1")
