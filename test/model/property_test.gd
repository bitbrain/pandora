# GdUnit generated TestSuite
class_name PropertyTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/model/property.gd"


func test_string_property() -> void:
	var property = PandoraProperty.new("123", "property", "string", "Hello World")
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_string_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "int", "Hello World")
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_int_property() -> void:
	var property = PandoraProperty.new("123", "property", "int", 123)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_int_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "string", 123)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_bool_property() -> void:
	var property = PandoraProperty.new("123", "property", "bool", true)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_bool_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "float", true)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_float_property() -> void:
	var property = PandoraProperty.new("123", "property", "float", 1.23)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_float_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "int", 1.23)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_color_property() -> void:
	var property = PandoraProperty.new("123", "property", "color", Color.RED)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_color_property_wrong_type() -> void:
	var property = PandoraProperty.new("123", "property", "reference", Color.RED)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_reference_property() -> void:
	var ref = PandoraReference.new("12345", 0)
	var property = PandoraProperty.new("123", "property", "reference", ref)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_reference_property_wrong_type() -> void:
	var ref = PandoraReference.new("12345", 0)
	var property = PandoraProperty.new("123", "property", "bool", ref)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_unknown_type() -> void:
	var property = PandoraProperty.new("123", "property", "unknown", "123")
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
	
	
func test_resource_property() -> void:
	var resource = load("res://splash.png")
	var property = PandoraProperty.new("123", "property", "resource", resource)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_equal(property)
	
	
func test_resource_property_wrong_type() -> void:
	var resource = load("res://splash.png")
	var property = PandoraProperty.new("123", "property", "string", resource)
	var new_property = PandoraProperty.new("", "", "", "")
	new_property.load_data(property.save_data())
	assert_that(new_property).is_not_equal(property)
