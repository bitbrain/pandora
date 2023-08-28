# GdUnit generated TestSuite
class_name PandoraEditorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/editor/pandora_editor.tscn"
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
	

func test_editor_loads() -> void:
	var root = Pandora.create_category("Root")
	var child_category = Pandora.create_category("Child Category", root)
	var entity = Pandora.create_entity("Child Entity", child_category)
	var weight_property = Pandora.create_property(root, "Weight", "float")
	weight_property.set_default_value(100.0)

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)

	await runner.simulate_frames(3)
	
	var tree = scene.tree as PandoraEntityTree
	assert_that(tree.entity_items.size()).is_equal(3)
