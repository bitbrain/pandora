# GdUnit generated TestSuite
class_name EntityIdFileGeneratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")


const EntityIdFileGenerator = preload("res://addons/pandora/util/entity_id_file_generator.gd")


func create_mock_entity(name: String, id: String) -> PandoraEntity:
	var entity = PandoraEntity.new()
	entity.set_entity_name(name)
	entity._id = id
	return entity


func create_mock_category(name: String, id: String, children: Array[PandoraEntity], generate_ids: bool) -> PandoraCategory:
	var category = PandoraCategory.new()
	category.set_entity_name(name)
	category._id = id
	category._children = children  # Ensure children is already of type Array[PandoraEntity]
	category._generate_ids = generate_ids
	category._ids_generation_class = name
	return category


func test_generate_class_to_entity_map_with_single_level() -> void:
	var entity1 = create_mock_entity("Item1", "id_item1")
	var category = create_mock_category("Items", "id_items", [entity1], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([category])

	assert_that(result.has("Items")).is_true()
	assert_that(result["Items"].size()).is_equal(1)
	assert_that(result["Items"][0]._id).is_equal("id_item1")


func test_generate_class_to_entity_map_with_nested_categories() -> void:
	var sub_entity1 = create_mock_entity("SubItem1", "id_subitem1")
	var sub_category = create_mock_category("SubItems", "id_subitems", [sub_entity1], true)
	var root_entity1 = create_mock_entity("RootItem1", "id_rootitem1")
	var root_category = create_mock_category("RootItems", "id_rootitems", [root_entity1, sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	assert_that(result.has("RootItems")).is_true()
	assert_that(result["RootItems"].size()).is_equal(2)
	assert_that(result["RootItems"][0]._id).is_equal("id_rootitem1")
	assert_that(result["RootItems"][1]._id).is_equal("id_subitem1")


func test_generate_class_to_entity_map_excludes_categories() -> void:
	var sub_category1 = create_mock_category("SubCat1", "id_subcat1", [], true)
	var root_category = create_mock_category("RootCat", "id_rootcat", [sub_category1], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	assert_that(result).is_empty()


func test_generate_class_to_entity_map_avoids_duplicates() -> void:
	var entity = create_mock_entity("Item", "id_item")
	var sub_category = create_mock_category("SubCategory", "id_subcategory", [entity], true)
	var root_category = create_mock_category("RootCategory", "id_rootcategory", [sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	var all_entities = []
	for entity_list in result.values():
		all_entities += entity_list

	assert_that(all_entities.size()).is_equal(1)
	assert_that(all_entities[0]._id).is_equal("id_item")

	var ids_dict = {}
	for entity1 in all_entities:
		ids_dict[entity1._id] = true

	assert_that(ids_dict.size()).is_equal(1)
