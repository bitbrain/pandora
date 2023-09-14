# GdUnit generated TestSuite
class_name PandoraArrayManagerTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/array_editor/array_manager.tscn"
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

func test_array_items_loaded() -> void:
	var root = Pandora.create_category("Root")
	var names_property = Pandora.create_property(root, "Names", "array")
	names_property.set_default_value(["John", "Jane"])
	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)

	await runner.simulate_frames(10, 5)

	scene.open(names_property)

	await runner.simulate_frames(10, 5)

	var items_count = scene._items.size()
	var container_items_count = scene.items_container.get_child_count()

	scene.close()

	assert_that(items_count).is_equal(2)
	assert_that(container_items_count).is_equal(2)
