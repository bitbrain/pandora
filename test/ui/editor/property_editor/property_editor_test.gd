# GdUnit generated TestSuite
class_name PandoraPropertyEditorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/editor/property_editor/property_editor.tscn"
const TEST_DIR = "testdata"


func before() -> void:
	Pandora.set_context_id(TEST_DIR)
	

func before_test() -> void:
	Pandora._clear()
	Pandora.load_data()

	
func after() -> void:
	DirAccess.remove_absolute("res://" + TEST_DIR + "/data.pandora")
	DirAccess.remove_absolute("res://" + TEST_DIR)
	Pandora.set_context_id("")
	Pandora._clear()
	Pandora.load_data()
	

func test_property_editor_loads() -> void:
	var root = Pandora.create_category("Root")
	var child_category = Pandora.create_category("Child Category", root)
	var entity = Pandora.create_entity("Child Entity", child_category)
	var weight_property = Pandora.create_property(root, "Weight", "float")
	weight_property.set_default_value(100.0)
	var age_property = Pandora.create_property(root, "Age", "int")
	weight_property.set_default_value(42)

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)

	await runner.simulate_frames(1)
	scene.set_entity(entity)
	await runner.simulate_frames(1)
	assert_that(scene.property_list.get_child_count()).is_equal(2)
