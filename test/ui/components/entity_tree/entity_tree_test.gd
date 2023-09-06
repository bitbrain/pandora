# GdUnit generated TestSuite
class_name EntityTreeTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/entity_tree/entity_tree.tscn"

var tree:PandoraEntityTree
var runner: GdUnitSceneRunner
var _backend_ref: PandoraEntityBackend

func before_test() -> void:
	tree = auto_free(load(__source).instantiate())
	runner = scene_runner(tree)
	_backend_ref = Pandora._entity_backend
	var id_generator := PandoraIDGenerator.new()
	Pandora._entity_backend = PandoraEntityBackend.new(id_generator)


func after_test() -> void:
	Pandora._entity_backend = _backend_ref


func test_populate_data() -> void:
	var backend = Pandora._entity_backend
	var parent = backend.create_category("Parent")
	var child1 = backend.create_category("Child1", parent)
	var child11 = backend.create_category("Child11", child1)
	var child111 = backend.create_category("Child111", child11)
	backend.create_entity("Entity111", child111)
	var all_data:Array[PandoraEntity] = []
	all_data.assign(backend.get_all_roots())
	tree.set_data(all_data)
	assert_that(tree.entity_items.size()).is_equal(5)

