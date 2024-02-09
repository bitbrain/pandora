## Generates a .gd file that allows for easier access
## of categories and subcategories of the data
static func regenerate_category_enums(root_categories: Array[PandoraCategory]) -> void:
	# Category_parent: {entity_name: entity_id}
	var category_enums = {}

	# Hack to get around array type casting
	var categories: Array[PandoraEntity]
	categories.assign(root_categories)

	for category in root_categories:
		regenerate_category_enums_for_category("RootCategories", categories, category_enums)

	regenerate_category_enum_file(category_enums)


static func regenerate_category_enums_for_category(
	parent_category: String, entities: Array[PandoraEntity], category_enums: Dictionary
) -> void:
	var enums = {}
	for entity in entities:
		if entity is PandoraCategory:
			enums[entity.get_entity_name()] = entity.get_entity_id()

			regenerate_category_enums_for_category(
				entity.get_entity_name(), entity._children, category_enums
			)

	if enums.size() > 0:
		category_enums[parent_category] = enums


static func regenerate_category_enum_file(enums: Dictionary) -> void:
	var file_path = "res://pandora/categories.gd"
	if not DirAccess.dir_exists_absolute("res://pandora"):
		DirAccess.make_dir_absolute("res://pandora")

	var file_access = FileAccess.open(file_path, FileAccess.WRITE)
	file_access.store_line("# Do not modify! Auto-generated file.")
	file_access.store_line("class_name PandoraCategories\n\n")

	for variable_name in enums.keys():
		var categories = []
		for category in enums[variable_name].keys():
			categories.append(
				"%s = %s" % [category.to_upper().replace(" ", "_"), enums[variable_name][category]]
			)
		var line = "enum %s {%s}" % [variable_name.to_pascal_case(), ", ".join(categories)]

		file_access.store_line(line)
	file_access.close()
