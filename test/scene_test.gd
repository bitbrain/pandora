# GdUnit generated TestSuite
class_name SceneTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://test/mock/mock_scene.tscn"
const TEST_DIR = "testdata"

func before() -> void:
	Pandora.set_context_id(TEST_DIR)
	
	
func after() -> void:
	DirAccess.remove_absolute("res://" + TEST_DIR + "/data.pandora")
	DirAccess.remove_absolute("res://" + TEST_DIR)


func test_initialize_scene() -> void:
	var category = Pandora.create_category("Swords")
	var entity = Pandora.create_entity("Iron Sword", category)
	var scene = load(__source).instantiate()
	scene.entity = entity
	var runner := scene_runner(scene)
	
	runner.simulate_frames(1)
	
	assert_that(scene.get_entity_instance()).is_not_null()
