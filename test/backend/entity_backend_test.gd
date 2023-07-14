# GdUnit generated TestSuite
class_name EntityBackendTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


# TestSuite generated from
const __source = "res://addons/pandora/backend/entity_backend.gd"


func create_object_backend() -> PandoraEntityBackend:
	return PandoraEntityBackend.new()
	
	
func create_instance_backend() -> PandoraEntityInstanceBackend:
	return PandoraEntityInstanceBackend.new()


func test_create_entity() -> void:
	var backend = create_object_backend()
	var category = backend.create_category("a")
	var entity = backend.create_entity("Test", category)
	assert_that(entity._id).is_not_null()
	assert_that(category._children).is_equal([entity])
	

func test_create_category() -> void:
	var backend = create_object_backend()
	var category = backend.create_category("Test")
	assert_that(category._id).is_not_null()
	
	
func test_delete_entity_instance() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("a")
	var entity = backend.create_entity("Test", category)
	var instance = instance_backend.create_entity_instance(entity)
	instance_backend.delete_entity_instance(instance.get_entity_instance_id())
	assert_that(instance_backend.get_entity_instance(instance.get_entity_instance_id())).is_null()
	
	
func test_create_property_after_entity_creation() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("a")
	backend.create_property(category, "key1", "string", "foobar1")
	var entity = backend.create_entity("Test", category)
	backend.create_property(category, "key2", "string", "foobar2")
	var entity_instance = instance_backend.create_entity_instance(entity)
	assert_that(entity_instance.get_string("key1")).is_equal("foobar1")
	assert_that(entity_instance.get_string("key2")).is_equal("foobar2")
	
	
func test_entity_inherits_properties_from_category_hierarchy() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category_parent = backend.create_category("parent-category")
	var parent_entity = backend.create_entity("parent_entity", category_parent)
	var category_child = backend.create_category("child-category", category_parent)
	var child_entity = backend.create_entity("child_entity", category_child)
	backend.create_property(category_parent, "key1", "string", "foobar1")
	backend.create_property(category_child, "key2", "string", "foobar2")
	var parent_instance = instance_backend.create_entity_instance(parent_entity)
	var child_instance = instance_backend.create_entity_instance(child_entity)
	assert_that(parent_instance.get_string("key1")).is_equal("foobar1")
	assert_that(child_instance.get_string("key1")).is_equal("foobar1")
	assert_that(parent_instance.get_string("key2")).is_equal("")
	assert_that(child_instance.get_string("key2")).is_equal("foobar2")
	
	
func test_entity_instance_data_type_lookup_bool() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "bool", true)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_bool("some-property")).is_equal(true)
	
	
func test_entity_instance_data_type_lookup_int() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "int", 42)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_integer("some-property")).is_equal(42)
	
	
func test_entity_instance_data_type_lookup_float() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "float", 42.0)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_float("some-property")).is_equal(42.0)


func test_entity_instance_data_type_lookup_color() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("entity", category)
	backend.create_property(category, "some-property", "color", Color.RED)
	var instance = instance_backend.create_entity_instance(entity)
	assert_that(instance.get_color("some-property")).is_equal(Color.RED)


func test_save_and_load_data() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var old_entities = backend._entities
	var old_categories = backend._categories
	var category_a = backend.create_category("a")
	var category_b = backend.create_category("b")
	var category_c = backend.create_category("c", category_b)
	backend.create_entity("a", category_a)
	backend.create_entity("b", category_b)
	backend.create_property(category_c, "property1", "string", "Hello World")
	var data = backend.save_data()
	assert_that(data._categories).is_not_null()
	assert_that(data._entities).is_not_null()
	
	backend.load_data(data)
	
	assert_that(old_entities).is_equal(backend._entities)
	assert_that(old_categories).is_equal(backend._categories)
	

func test_inherit_correct_properties() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	
	var root_category = backend.create_category("root")
	var category_a = backend.create_category("category A", root_category)
	var category_b = backend.create_category("category B", root_category)
	
	backend.create_property(root_category, "root property", "string", "foobar")
	
	assert_that(category_a.get_entity_property("root property")).is_not_null()
	assert_that(category_b.get_entity_property("root property")).is_not_null()
	
	backend.create_property(category_a, "cat a property1", "string", "foobar1")
	
	backend.create_property(category_a, "cat a property2", "string", "foobar2")
	
	var entity_a = backend.create_entity("Entity A", category_a)
	var entity_b = backend.create_entity("Entity B", category_b)
	
	assert_that(entity_a.get_entity_property("root property")).is_not_null()
	assert_that(entity_a.get_entity_property("cat a property1")).is_not_null()
	assert_that(entity_a.get_entity_property("cat a property2")).is_not_null()
	
	assert_that(entity_b.get_entity_property("root property")).is_not_null()
	assert_that(entity_b.get_entity_property("cat a property1")).is_null()
	assert_that(entity_b.get_entity_property("cat a property2")).is_null()

	
func test_inherit_correct_properties_after_reloading() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	
	var root_category = backend.create_category("root")
	var category_a = backend.create_category("category A", root_category)
	var category_b = backend.create_category("category B", root_category)
	
	backend.create_property(root_category, "root property", "string", "foobar")
	backend.create_property(category_a, "cat a property1", "string", "foobar1")
	backend.create_property(category_a, "cat a property2", "string", "foobar2")
	
	var entity_a_old = backend.create_entity("Entity A", category_a)
	var entity_b_old = backend.create_entity("Entity B", category_b)
	
	var entity_a_id = entity_a_old.get_entity_id()
	var entity_b_id = entity_b_old.get_entity_id()
	
	var data = backend.save_data()
	backend.load_data(data)
	
	var entity_a = backend.get_entity(entity_a_id)
	var entity_b = backend.get_entity(entity_b_id)
	
	assert_that(entity_a.get_entity_property("root property")).is_not_null()
	assert_that(entity_a.get_entity_property("cat a property1")).is_not_null()
	assert_that(entity_a.get_entity_property("cat a property2")).is_not_null()
	
	assert_that(entity_b.get_entity_property("root property")).is_not_null()
	assert_that(entity_b.get_entity_property("cat a property1")).is_null()
	assert_that(entity_b.get_entity_property("cat a property2")).is_null()


func test_inherit_overridden_properties_after_reloading() -> void:
	var backend = create_object_backend() as PandoraEntityBackend

	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "foobar")

	var category_a = backend.create_category("category A", root_category)
	var overridden_property = category_a.get_entity_property("root property")
	overridden_property.set_default_value("override")

	var entity_a_old = backend.create_entity("Entity A", category_a)
	var entity_a_id = entity_a_old.get_entity_id()

	var data = backend.save_data()
	backend.load_data(data)

	var entity_a = backend.get_entity(entity_a_id)

	assert_that(entity_a.get_entity_property("root property")).is_not_null()
	assert_that(entity_a.get_entity_property("root property").get_default_value()).is_equal("override")
	
	
func test_save_parent_changed_property_name() -> void:
	var backend = create_object_backend() as PandoraEntityBackend

	var root_category = backend.create_category("root")
	var root_property = backend.create_property(root_category, "root property", "string", "foobar")

	var child_category = backend.create_category("category child", root_category)
	var child_child_category = backend.create_category("category child child", child_category)
	var entity = backend.create_entity("Child Entity", child_child_category)
	var overridden_property = child_category.get_entity_property("root property")
	overridden_property.set_default_value("override")
	
	root_property._name = "changed property"
	
	var data = backend.save_data()
	backend.load_data(data)
	
	var loaded_entity = backend.get_entity(entity.get_entity_id())
	var loaded_property = loaded_entity.get_entity_property("changed property")
	assert_that(loaded_property.get_default_value()).is_equal("override")

	
func test_property_override() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	
	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "foobar")
	
	var category_a = backend.create_category("category A", root_category)
	var entity_a = backend.create_entity("Entity A", category_a)
	
	var root_property = entity_a.get_entity_property("root property")
	
	root_property.set_default_value("override")
	
	assert_that(root_property.get_default_value()).is_equal("override")


func test_inherit_property_from_parent_category() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "foobar")

	var category_a = backend.create_category("category A", root_category)
	var entity_a = backend.create_entity("Entity A", category_a)
	var root_property = entity_a.get_entity_property("root property")

	assert_that(root_property.get_default_value()).is_equal("foobar")


func test_override_property_value() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "foobar")

	var category_a = backend.create_category("category A", root_category)
	var entity_a = backend.create_entity("Entity A", category_a)
	var root_property = entity_a.get_entity_property("root property")

	root_property.set_default_value("override1")
	assert_that(root_property.get_default_value()).is_equal("override1")


func test_inherit_overridden_property() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "foobar")

	var category_a = backend.create_category("category A", root_category)
	backend.create_property(category_a, "cat a property", "string", "override1")

	var entity_a = backend.create_entity("Entity A", category_a)
	var cat_a_property = entity_a.get_entity_property("cat a property")

	var category_b = backend.create_category("category B", category_a)
	var entity_b = backend.create_entity("Entity B", category_b)
	var cat_a_property_b = entity_b.get_entity_property("cat a property")

	assert_that(cat_a_property_b.get_default_value()).is_equal(cat_a_property.get_default_value())


func test_override_inherited_property() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "foobar")

	var category_a = backend.create_category("category A", root_category)
	var entity_a = backend.create_entity("Entity A", category_a)
	var root_property = entity_a.get_entity_property("root property")
	root_property.set_default_value("override1")

	var category_b = backend.create_category("category B", category_a)
	var entity_b = backend.create_entity("Entity B", category_b)
	var root_property_b = entity_b.get_entity_property("root property")

	root_property_b.set_default_value("override2")
	assert_that(root_property_b.get_default_value()).is_equal("override2")


func test_entity_instance_inherits_properties() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	backend.create_property(category, "property1", "string", "value1")
	var entity = backend.create_entity("Test", category)
	var entity_instance = instance_backend.create_entity_instance(entity)
	assert_that(entity_instance.get_string("property1")).is_equal("value1")


func test_entity_instance_inherits_overridden_properties() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var root_category = backend.create_category("root")
	backend.create_property(root_category, "root property", "string", "rootValue")
	var child_category = backend.create_category("child", root_category)
	var entity = backend.create_entity("Test", child_category)
	var root_property = entity.get_entity_property("root property")
	root_property.set_default_value("override")
	var entity_instance = instance_backend.create_entity_instance(entity)
	assert_that(entity_instance.get_string("root property")).is_equal("override")


func test_entity_instance_does_not_inherit_late_properties() -> void:
	var backend = create_object_backend()
	var instance_backend = create_instance_backend()
	var category = backend.create_category("category")
	var entity = backend.create_entity("Test", category)
	var entity_instance = instance_backend.create_entity_instance(entity)
	backend.create_property(category, "late property", "string", "lateValue")
	assert_that(entity_instance.get_string("late property")).is_equal("")
	
	
func test_save_and_load_instance_data() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var instance_backend = create_instance_backend() as PandoraEntityInstanceBackend
	var category = backend.create_category("category")
	backend.create_property(category, "property", "string", "Hello World")
	var entity = backend.create_entity("Test", category)
	var old_instance = instance_backend.create_entity_instance(entity)
	var data = instance_backend.save_data()

	assert_that(data._instances).is_not_null()

	instance_backend.load_data(data, backend)
	var new_instance = instance_backend.get_entity_instance(old_instance.get_entity_instance_id())

	assert_that(old_instance.get_entity_instance_id()).is_equal(new_instance.get_entity_instance_id())


func test_load_correct_instance_properties_after_save() -> void:
	var backend = create_object_backend() as PandoraEntityBackend
	var instance_backend = create_instance_backend() as PandoraEntityInstanceBackend
	var category = backend.create_category("category")
	backend.create_property(category, "property", "string", "Hello World")
	var entity = backend.create_entity("Test", category)
	var old_instance = instance_backend.create_entity_instance(entity)
	print("instance id", old_instance.get_entity_instance_id())
	old_instance.set_string("property", "Override")
	
	var data = instance_backend.save_data()
	instance_backend.load_data(data, backend)
	var new_instance = instance_backend.get_entity_instance(old_instance.get_entity_instance_id())
	
	assert_that(new_instance.get_string("property")).is_equal("Override")
