# GdUnit generated TestSuite
class_name ApiTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/api.gd"
const TEST_DIR = "testdata"

func before() -> void:
	Pandora.set_context_id(TEST_DIR)
	Pandora._clear()
	
	
func after() -> void:
	DirAccess.remove_absolute("res://" + TEST_DIR + "/data.pandora")
	DirAccess.remove_absolute("res://" + TEST_DIR)
	Pandora.set_context_id("")
	Pandora._clear()
	Pandora.load_data()

func test_api_save_and_load_objects() -> void:
	var category = Pandora.create_category("Swords")
	var category_id = category._id
	var entity = Pandora.create_entity("Zweihander", category)
	var entity_id = entity._id
	Pandora.save_data()
	Pandora._clear()
	Pandora.load_data()
	assert_that(Pandora.get_category(category_id)).is_not_null()
	assert_that(Pandora.get_entity(entity_id)).is_not_null()


func _save_load_instance() -> void:
	var category = Pandora.create_category("Swords")
	var entity = Pandora.create_entity("Zweihander", category)
	var instance = entity.instantiate()
	var data = Pandora.serialize(instance)
	var new_instance = Pandora.deserialize(data)
	
	assert_that(instance).is_equal(new_instance)


# FIXME: currently needs to run as part of Pandora lifecycle
# due to scripts relying on Pandora directly
# via singleton
func test_save_and_load_reference() -> void:
	var items = Pandora.create_category("items")
	Pandora.create_property(items, "Material", "reference")
	var materials = Pandora.create_category("materials")
	Pandora.create_property(materials, "Material Name", "string")
	var iron = Pandora.create_entity("Iron", materials)
	iron.get_entity_property("Material Name").set_default_value("Iron")
	var iron_sword = Pandora.create_entity("Iron Sword", items)
	iron_sword.get_entity_property("Material").set_default_value(iron)
	
	Pandora.save_data()
	Pandora._clear()
	Pandora.load_data()
	
	iron = Pandora.get_entity(iron.get_entity_id())
	var loaded_iron_sword = Pandora.get_entity(iron_sword.get_entity_id())
	var referenced_material = loaded_iron_sword.get_reference("Material")
	assert_that(referenced_material).is_equal(iron)


func test_entity_is_category() -> void:
	var items = Pandora.create_category("items")
	var weapons = Pandora.create_category("weapons", items)
	var quests = Pandora.create_category("quests")
	var sword = Pandora.create_entity("Sword", weapons)
	
	assert_bool(sword.is_category(items.get_entity_id())).is_true()
	assert_bool(sword.is_category(weapons.get_entity_id())).is_true()
	assert_bool(sword.is_category(quests.get_entity_id())).is_false()
