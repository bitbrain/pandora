# GdUnit generated TestSuite
class_name PropertyTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/model/property.gd"


func test_string_property() -> void:
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value("Hello World")
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_string_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "reference")
	property.set_default_value("Hello World")
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_null()


func test_int_property() -> void:
	var property = PandoraProperty.new("123", "property", "int")
	property.set_default_value(123)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_int_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value(123)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")


func test_bool_property() -> void:
	var property = PandoraProperty.new("123", "property", "bool")
	property.set_default_value(true)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_bool_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "float")
	property.set_default_value(false)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal(0.0)


func test_float_property() -> void:
	var property = PandoraProperty.new("123", "property", "float")
	property.set_default_value(10.3)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_float_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "int")
	property.set_default_value(1.23)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal(0)


func test_color_property() -> void:
	var property = PandoraProperty.new("123", "property", "color")
	property.set_default_value(Color.RED)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_color_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "reference")
	property.set_default_value(Color.RED)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_null()


func test_reference_property() -> void:
	var ref = PandoraReference.new("12345", 0)
	var property = PandoraProperty.new("123", "property", "reference")
	property.set_default_value(ref)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_reference_property_wrong_type() -> void:
	var ref = PandoraReference.new("12345", 0)
	var property = PandoraProperty.new("123", "property", "bool")
	property.set_default_value(ref)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_bool(new_property.get_default_value()).is_false()


func test_unknown_type() -> void:
	var property = PandoraProperty.new("123", "property", "unknown")
	property.set_default_value( "123")
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_null()


func test_resource_property() -> void:
	var resource = load("res://splash.png")
	var property = PandoraProperty.new("123", "property", "resource")
	property.set_default_value(resource)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)


func test_resource_property_wrong_type() -> void:
	var resource = load("res://splash.png")
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value(resource)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")

func test_array_property() -> void:
	var property = PandoraProperty.new("123", "property", "array")
	property.set_default_value([1, 2, 3])
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)

func test_array_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value([1, 2, 3])
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")

func test_array_property_custom_parsers() -> void:
	var array_type = load("res://addons/pandora/model/types/array.gd")
	var category = Pandora.create_category("Test Category")
	var property = Pandora.create_property(category, "property", "array")
	property.set_setting_override(array_type.SETTING_ARRAY_TYPE, "color")
	var entity = Pandora.create_entity("entity", category)
	var entity_property = entity.get_entity_property("property")
	entity_property.set_default_value([Color.WHITE])
	entity.load_data(entity.save_data())
	assert_that(entity.get_array("property")[0]).is_equal(Color.WHITE)
	assert_that(typeof(entity.get_array("property")[0])).is_not_equal(TYPE_STRING)

func test_vector2_property() -> void:
	var vector = Vector2.ONE
	var property = PandoraProperty.new("123", "property", "vector2")
	property.set_default_value(vector)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)

func test_vector2_property_wrong_type() -> void:
	var resource = Vector2.ONE
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value(resource)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")

func test_vector2i_property() -> void:
	var vector = Vector2i.ONE
	var property = PandoraProperty.new("123", "property", "vector2i")
	property.set_default_value(vector)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)

func test_vector2i_property_wrong_type() -> void:
	var resource = Vector2i.ONE
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value(resource)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")

func test_vector3_property() -> void:
	var vector = Vector3.ONE
	var property = PandoraProperty.new("123", "property", "vector3")
	property.set_default_value(vector)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)

func test_vector3_property_wrong_type() -> void:
	var resource = Vector3.ONE
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value(resource)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")

func test_vector3i_property() -> void:
	var vector = Vector3i.ONE
	var property = PandoraProperty.new("123", "property", "vector3i")
	property.set_default_value(vector)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)

func test_vector3i_property_wrong_type() -> void:
	var resource = Vector3i.ONE
	var property = PandoraProperty.new("123", "property", "string")
	property.set_default_value(resource)
	var new_property = PandoraProperty.new("", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property.get_default_value()).is_equal("")
