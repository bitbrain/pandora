# GdUnit generated TestSuite
class_name PandoraControlKvpTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const PropertyControl = preload("res://addons/pandora/ui/components/properties/property_control.gd")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/properties/property_control_kvp.tscn"


func test_signal_original_property_selected() -> void:
	var id_generator = PandoraIDGenerator.new()
	var backend = PandoraEntityBackend.new(id_generator)
	var root_category = backend.create_category("root")
	var property = backend.create_property(root_category, "Weight", "float")
	var inner_control = PropertyControl.new()
	
   
	var runner = scene_runner(__source)
	var control = runner.scene()
	# create a signal monitor to watch the control
	var signal_monitor := monitor_signals(control)
	control.init(property, inner_control, backend)
	control._ready()
	
	# wait 50ms
	await runner.simulate_frames(10, 5)
	
	runner.set_mouse_pos(control.property_key_edit.position + Vector2(10, 10))
	runner.simulate_mouse_button_press(MOUSE_BUTTON_LEFT)
	
	await assert_signal(signal_monitor).wait_until(50).is_emitted('original_property_selected', [property])
