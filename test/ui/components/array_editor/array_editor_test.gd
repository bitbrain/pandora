# GdUnit generated TestSuite
class_name PandoraArrayEditorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/ui/components/array_editor/array_editor.tscn"
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

func test_array_info_label() -> void:
	var root = Pandora.create_category("Root")
	var names_property = Pandora.create_property(root, "Names", "array")
	names_property.set_default_value(["John", "Jane"])

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)
	
	await runner.simulate_frames(1)
	scene.set_property(names_property)
	await runner.simulate_frames(1)
	assert_that(scene.array_info.text).is_equal("2 Entries")

func test_array_window_opening() -> void:
	var root = Pandora.create_category("Root")
	var names_property = Pandora.create_property(root, "Names", "array")

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)
	var signal_monitor := monitor_signals(scene.array_window)

	await runner.simulate_frames(1)

	scene.set_property(names_property)

	await runner.simulate_frames(10, 5)

	runner.set_mouse_pos(scene.edit_button.position + Vector2(10, 10))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	await runner.simulate_frames(10, 5)

	scene.array_window._on_close_requested()

	await assert_signal(signal_monitor).wait_until(500).is_emitted('about_to_popup')

func test_create_reference_array() -> void:
	var root = Pandora.create_category("Root")
	var items = Pandora.create_category("Items", root)
	var item = Pandora.create_entity("Item 1", items)
	var npcs = Pandora.create_category("NPCs", root)
	var items_prop: PandoraProperty = Pandora.create_property(npcs, "Items", "array")
	items_prop.set_setting_override("Array Type", "reference")
	var npc = Pandora.create_entity("Npc 1", npcs)
	items_prop.set_setting_override("Array Type", "reference")
	items_prop.set_setting_override("Category Filter", items.get_entity_id())
	var ref = PandoraReference.new(item.get_entity_id(), PandoraReference.Type.ENTITY).save_data()
	npc.get_entity_property("Items").set_default_value([ref])

	Pandora.save_data()
	Pandora._clear()
	Pandora.load_data()

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)
	var signal_monitor = monitor_signals(scene.array_window)
	await runner.simulate_frames(1)

	scene.set_property(npc.get_entity_property("Items"))

	await runner.simulate_frames(10, 5)

	runner.set_mouse_pos(scene.edit_button.position + Vector2(10, 10))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	await runner.simulate_frames(10, 5)

	runner.set_mouse_pos(scene.array_window.array_manager.close_button.position + Vector2(10, 10))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	scene.array_window._on_close_requested()

	await assert_signal(signal_monitor).wait_until(500).is_not_emitted('item_removed', [ref])
