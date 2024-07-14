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


func test_generate_class_to_entity_map_avoids_duplicates_within_category() -> void:
	var entity = create_mock_entity("Item", "id_item")
	var sub_category = create_mock_category("SubCategory", "id_subcategory", [entity], true)
	var root_category = create_mock_category("RootCategory", "id_rootcategory", [sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	# Collect all entities within "RootCategory" and "SubCategory"
	var root_category_entities = result["RootCategory"]
	var sub_category_entities = result["SubCategory"]

	# Ensure "RootCategory" has 1 entity and it is the correct one
	assert_that(root_category_entities.size()).is_equal(1)
	assert_that(root_category_entities[0]._id).is_equal("id_item")

	# Ensure "SubCategory" has 1 entity and it is the correct one
	assert_that(sub_category_entities.size()).is_equal(1)
	assert_that(sub_category_entities[0]._id).is_equal("id_item")

	# Use a dictionary to track unique IDs within each category
	var root_ids_dict = {}
	for entity1 in root_category_entities:
		root_ids_dict[entity1._id] = true

	var sub_ids_dict = {}
	for entity2 in sub_category_entities:
		sub_ids_dict[entity2._id] = true

	# The size of ids_dict should be 1 for each category if all entries are unique within that category
	assert_that(root_ids_dict.size()).is_equal(1)
	assert_that(sub_ids_dict.size()).is_equal(1)


func test_root_category_generates_file_with_child_entity() -> void:
	var entity = create_mock_entity("Item", "id_item")
	var sub_category = create_mock_category("SubCategory", "id_subcategory", [entity], true)
	var root_category = create_mock_category("RootCategory", "id_rootcategory", [sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	# Verify that the root category produces a file with the entity from the child category
	assert_that(result.has("RootCategory")).is_true()
	assert_that(result["RootCategory"].size()).is_equal(1)
	assert_that(result["RootCategory"][0]._id).is_equal("id_item")


func test_child_category_generates_file_with_entity() -> void:
	var entity = create_mock_entity("Item", "id_item")
	var sub_category = create_mock_category("SubCategory", "id_subcategory", [entity], true)
	var root_category = create_mock_category("RootCategory", "id_rootcategory", [sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	# Verify that the child category generates a file with the entity
	assert_that(result.has("SubCategory")).is_true()
	assert_that(result["SubCategory"].size()).is_equal(1)
	assert_that(result["SubCategory"][0]._id).is_equal("id_item")


func test_no_duplicate_entities_within_each_key() -> void:
	var entity = create_mock_entity("Item", "id_item")
	var sub_category = create_mock_category("SubCategory", "id_subcategory", [entity], true)
	var root_category = create_mock_category("RootCategory", "id_rootcategory", [sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	# Verify that there are no duplicate entities for each key
	for key in result.keys():
		var ids_dict = {}
		for e in result[key]:
			ids_dict[e._id] = true
		assert_that(ids_dict.size()).is_equal(result[key].size())


func test_entity_exists_in_both_parent_and_child_keys() -> void:
	var entity = create_mock_entity("Item", "id_item")
	var sub_category = create_mock_category("SubCategory", "id_subcategory", [entity], true)
	var root_category = create_mock_category("RootCategory", "id_rootcategory", [sub_category], true)

	var result = EntityIdFileGenerator.generate_class_to_entity_map([root_category])

	# Verify that entities can exist in both parent and child keys
	var all_entities = []
	for entity_list in result.values():
		all_entities += entity_list

	# Verify that there are no duplicate entities across all keys
	var overall_ids_dict = {}
	for e in all_entities:
		overall_ids_dict[e._id] =  overall_ids_dict[e._id] + 1 if overall_ids_dict.has(e._id) else 1

	# Ensure no entity appears more than once across all keys
	for entity_id in overall_ids_dict.keys():
		assert_that(overall_ids_dict[entity_id]).is_equal(2)  # Each entity should appear twice: once in parent and once in child
