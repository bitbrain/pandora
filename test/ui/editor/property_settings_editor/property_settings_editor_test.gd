# GdUnit generated TestSuite
class_name PandoraPropertySettingsEditorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const EXAMPLE_SETTINGS = {
		"Bool Setting": {
			"type": "bool",
			"value": false
		},
		"Int Setting": {
			"type": "int",
			"value": 123
		},
		"Float Setting": {
			"type": "float",
			"value": 123.5
		},
		"Color Setting": {
			"type": "color",
			"value": Color.RED
		},
		"Reference Setting": {
			"type": "reference",
			"value": ""
		},
		"Resource Setting": {
			"type": "resource",
			"value": ""
		},
		"String Setting (Multi)": {
			"type": "string",
			"options": [
				"Option A",
				"Option B"
			],
			"value": "Option B"
		},
		"String Setting (Single)": {
			"type": "string",
			"value": "Some Value"
		}
	}
	
	
# TestSuite generated from
const __source = "res://addons/pandora/ui/editor/property_settings_editor/property_settings_editor.tscn"


func test_create_settings_ui() -> void:
	var id_generator = PandoraIDGenerator.new()
	var backend = PandoraEntityBackend.new(id_generator)
	var root_category = backend.create_category("root")
	var property = backend.create_property(root_category, "Weight", "reference")
	var control = auto_free(load(__source).instantiate())
	var runner = scene_runner(control)
	control.set_property(property)
	
	assert_that(control.properties_settings.get_child_count()).is_equal(3)
	
	
	
	
