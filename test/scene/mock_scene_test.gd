class_name MockSceneTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://test/mock/mock_scene.tscn"


func test_instantiate_mock_data_via_scene() -> void:
	var tree = auto_free(load(__source).instantiate())
	var runner = scene_runner(tree)
	
	await runner.simulate_frames(1)
	
	assert_that(tree.get_entity_instance()).is_not_null()
	assert_bool(tree.get_entity_instance() is CustomMockEntity).is_true()
