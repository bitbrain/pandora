# GdUnit generated TestSuite
class_name CategoryIdFileGeneratorTest
extends GdUnitTestSuite
@warning_ignore("unused_parameter")
@warning_ignore("return_value_discarded")

const CategoryIdFileGenerator = preload("res://addons/pandora/util/category_id_file_generator.gd")

func create_mock_root_category(name: String, id: String, children: Array[PandoraEntity] = []) -> PandoraCategory:
	var category = PandoraCategory.new()
	category.set_entity_name(name)
	category._id = id
	category._children = children
	return category

func create_mock_sub_category(name: String, id: String) -> PandoraCategory:
	var sub_category = PandoraCategory.new()
	sub_category.set_entity_name(name)
	sub_category._id = id
	var empty_array: Array[PandoraEntity] = []
	sub_category._children = empty_array
	return sub_category

func test_generate_parent_category_tuples_with_single_root() -> void:
	var root_category: PandoraCategory = create_mock_root_category("Root1", "id_root1")
	var root_categories: Array[PandoraCategory] = [root_category]

	var result = CategoryIdFileGenerator.generate_parent_category_tuples(root_categories)

	assert_that(result.size()).is_equal(1)
	assert_that(result[0].category_name).is_equal("Root1")
	assert_that(result[0].category_id).is_equal("id_root1")

func test_generate_parent_category_tuples_with_multiple_roots() -> void:
	var root_category1: PandoraCategory = create_mock_root_category("Root1", "id_root1")
	var root_category2: PandoraCategory = create_mock_root_category("Root2", "id_root2")
	var root_categories: Array[PandoraCategory] = [root_category1, root_category2]

	var result = CategoryIdFileGenerator.generate_parent_category_tuples(root_categories)

	assert_that(result.size()).is_equal(2)
	assert_that(result[0].category_name).is_equal("Root1")
	assert_that(result[0].category_id).is_equal("id_root1")
	assert_that(result[1].category_name).is_equal("Root2")
	assert_that(result[1].category_id).is_equal("id_root2")

func test_generate_sub_category_tuples_with_single_root_and_subcategories() -> void:
	var sub_category1: PandoraCategory = create_mock_sub_category("Sub1", "id_sub1")
	var sub_category2: PandoraCategory = create_mock_sub_category("Sub2", "id_sub2")
	var root_category: PandoraCategory = create_mock_root_category("Root1", "id_root1", [sub_category1, sub_category2])
	var root_categories: Array[PandoraCategory] = [root_category]

	var result: Dictionary = CategoryIdFileGenerator.generate_sub_category_tuples(root_categories)

	assert_that(result.size()).is_equal(1)
	assert_that(result.has("Root1")).is_true()
	assert_that(result["Root1"].size()).is_equal(2)
	assert_that(result["Root1"][0].category_name).is_equal("Sub1")
	assert_that(result["Root1"][0].category_id).is_equal("id_sub1")
	assert_that(result["Root1"][1].category_name).is_equal("Sub2")
	assert_that(result["Root1"][1].category_id).is_equal("id_sub2")


func test_generate_sub_category_tuples_with_nested_subcategories() -> void:
	var sub_sub_category1: PandoraCategory = create_mock_sub_category("SubSub1", "id_subsub1")
	var sub_category1: PandoraCategory = create_mock_sub_category("Sub1", "id_sub1")
	sub_category1._children.append(sub_sub_category1)
	var root_category: PandoraCategory = create_mock_root_category("Root1", "id_root1", [sub_category1])
	var root_categories: Array[PandoraCategory] = [root_category]

	var result: Dictionary = CategoryIdFileGenerator.generate_sub_category_tuples(root_categories)

	# Correct key for the first level of nesting
	var first_key = "Root1"
	var second_key = "Root1_Sub1"

	assert_that(result.size()).is_equal(2)
	assert_that(result.has(first_key)).is_true()
	assert_that(result[first_key].size()).is_equal(1)
	assert_that(result[first_key][0].category_name).is_equal("Sub1")
	assert_that(result[first_key][0].category_id).is_equal("id_sub1")

	assert_that(result.has(second_key)).is_true()
	assert_that(result[second_key].size()).is_equal(1)
	assert_that(result[second_key][0].category_name).is_equal("SubSub1")
	assert_that(result[second_key][0].category_id).is_equal("id_subsub1")
