# GdUnit generated TestSuite
class_name IdGeneratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/utils/id_generator.gd"
	

# COMMENT IN MANUALLY
#func test_no_collisions_100k_iterations() -> void:
#	_assert_no_collisions(100000)
	
	
func test_generate_id() -> void:
	var id_generator = preload(__source)
	assert_that(id_generator.generate(123)).is_equal("12312312343782474")
	assert_that(id_generator.generate(9876)).is_equal("98769876987684013760")
	
	
func _assert_no_collisions(iterations: int) -> void:
	var id_generator = preload(__source)
	var generated_ids:Array[String] = []
	var collisions = 0
	for i in range(0, iterations):
		var id = id_generator.generate()
		if generated_ids.has(id):
			collisions += 1
		else:
			generated_ids.append(id)
	assert_that(collisions).is_equal(0)
