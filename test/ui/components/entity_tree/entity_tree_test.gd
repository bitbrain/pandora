# GdUnit generated TestSuite
class_name EntityTreeTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/entity_tree/entity_tree.tscn"

var tree:PandoraEntityTree
var runner: GdUnitSceneRunner

func before_test() -> void:
	tree = auto_free(load(__source).instantiate())
	runner = scene_runner(tree)
	Pandora._clear()


func test_populate_data() -> void:
	var parent = Pandora.create_category("Parent")
	var child1 = Pandora.create_category("Child1", parent)
	var child11 = Pandora.create_category("Child11", child1)
	var child111 = Pandora.create_category("Child111", child11)
	Pandora.create_entity("Entity111", child111)
	var all_data:Array[PandoraEntity] = []
	all_data.assign(Pandora.get_all_categories())
	tree.set_data(all_data)
	assert_that(tree.entity_items.size()).is_equal(5)

