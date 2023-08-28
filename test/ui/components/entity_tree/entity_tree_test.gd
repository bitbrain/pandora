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


func test_populate_data() -> void:
	var id_generator = PandoraIdGenerator.new()
	var backend = PandoraEntityBackend.new(id_generator)
	var parent = backend.create_category("Parent")
	var child1 = backend.create_category("Child1", parent)
	var child11 = backend.create_category("Child11", child1)
	var child111 = backend.create_category("Child111", child11)
	backend.create_entity("Entity111", child111)
	var all_data:Array[PandoraEntity] = []
	all_data.assign(backend.get_all_roots())
	tree.set_data(all_data)
	assert_that(tree.entity_items.size()).is_equal(5)

