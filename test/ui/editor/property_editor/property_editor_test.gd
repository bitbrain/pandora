# GdUnit generated TestSuite
class_name PandoraPropertyEditorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const ArrayType = preload("res://addons/pandora/model/types/array.gd")
const ReferenceType = preload("res://addons/pandora/model/types/reference.gd")
const __source = "res://addons/pandora/ui/editor/property_editor/property_editor.tscn"
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
	

func test_property_editor_loads() -> void:
	var root = Pandora.create_category("Root")
	var child_category = Pandora.create_category("Child Category", root)
	var entity = Pandora.create_entity("Child Entity", child_category)
	var weight_property = Pandora.create_property(root, "Weight", "float")
	weight_property.set_default_value(100.0)
	var age_property = Pandora.create_property(root, "Age", "int")
	age_property.set_default_value(42)

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)

	await runner.simulate_frames(1)
	scene.set_entity(entity)
	await runner.simulate_frames(1)
	assert_that(scene.property_list.get_child_count()).is_equal(2)

func test_array_property_items_creation() -> void:
	var root = Pandora.create_category("Root")
	var merchants_category = Pandora.create_category("Merchants", root)
	var merchant_entity = Pandora.create_entity("Louis", merchants_category)
	var items_category = Pandora.create_category("Items", root)
	var item_1 = Pandora.create_entity("Item 1", items_category)
	var _item_2 = Pandora.create_entity("Item 2", items_category)
	var array_property: PandoraProperty = Pandora.create_property(merchants_category, "Items for Sale", "array")
	array_property.set_setting_override(ArrayType.SETTING_ARRAY_TYPE, "reference")
	array_property.set_setting_override(ReferenceType.SETTING_CATEGORY_FILTER, str(items_category._id))
	array_property.set_default_value([item_1])

	var scene = auto_free(load(__source).instantiate())
	var runner = scene_runner(scene)

	await runner.simulate_frames(1)
	scene.set_entity(merchant_entity)
	await runner.simulate_frames(10, 5)

	var array_editor = scene.property_list.get_child(0).property_value.get_child(0).array_editor
	var edit_btn_pos = array_editor.edit_button.global_position

	runner.set_mouse_pos(edit_btn_pos + Vector2(10, 10))
	runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	await runner.simulate_frames(10, 5)

	var array_manager = array_editor.array_window.array_manager
	array_manager._add_new_item()
	await runner.simulate_frames(1)

	var option_button = array_manager.items_container.get_child(1)._control.entity_picker.option_button
	option_button.show_popup()
	await runner.simulate_frames(1)
	option_button.get_popup().set_focused_item(1)
	runner.simulate_key_pressed(KEY_ENTER)

	# add empty item
	array_manager._add_new_item()
	array_editor.array_window._on_close_requested()
	await runner.simulate_frames(10, 5)

	assert_that(merchant_entity.get_array("Items for Sale").size()).is_equal(2)
