# GdUnit generated TestSuite
class_name SceneTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://mock/mock_scene.tscn"
const TEST_DIR = "testdata"
const CUSTOM_ENTITY_PATH = "res://mock/custom_mock_entity.gd"

func before() -> void:
	Pandora.set_context_id(TEST_DIR)
	
	
func after() -> void:
	DirAccess.remove_absolute("res://" + TEST_DIR + "/data.pandora")
	DirAccess.remove_absolute("res://" + TEST_DIR)


func test_initialize_scene() -> void:
	var category = Pandora.create_category("Swords")
	category.set_script_path(CUSTOM_ENTITY_PATH)
	var entity = Pandora.create_entity("Iron Sword", category)
	var scene = auto_free(load(__source).instantiate())
	scene.entity = entity
	var runner := scene_runner(scene)
	
	await runner.simulate_frames(1)
	
	assert_that(scene.get_entity_instance()).is_not_null()
	assert_that(scene.get_category()).is_not_null()
