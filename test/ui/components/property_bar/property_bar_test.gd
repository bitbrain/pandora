# GdUnit generated TestSuite
class_name PandoraBarTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/property_bar/property_bar.tscn"


func test_all_property_scenes_added() -> void:
	var id_generator = PandoraIDGenerator.new()
	var backend = PandoraEntityBackend.new(id_generator)
	var root_category = backend.create_category("root")
	var property = backend.create_property(root_category, "Weight", "float")
	var control = auto_free(load(__source).instantiate())
	var runner = scene_runner(control)
	control.property_added.connect(func(scene): print("added!"))
	
	
	
