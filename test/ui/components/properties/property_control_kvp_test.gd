# GdUnit generated TestSuite
class_name PandoraControlKvpTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const PropertyControl = preload("res://addons/pandora/ui/components/properties/property_control.gd")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/properties/property_control_kvp.tscn"


func test_signal_original_property_selected() -> void:
	var id_generator = NanoIDGenerator.new(NanoIDAlphabets.URL, 9)
	var backend = PandoraEntityBackend.new(id_generator)
	var root_category = backend.create_category("root")
	var property = backend.create_property(root_category, "Weight", "float")
	var inner_control = PropertyControl.new()
	
	var control = auto_free(load(__source).instantiate())
	var control_spy = spy(control)
	control.init(property, inner_control, backend)
	var runner = scene_runner(control)
	
	# wait 50ms
	await runner.simulate_frames(10, 5)
	
	runner.set_mouse_pos(control.property_key_edit.position + Vector2(10, 10))
	await runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	
	# FIXME: improve test by testing actual signal
	verify(control_spy)._property_key_focused()
