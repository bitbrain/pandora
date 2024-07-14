const Tokenizer = preload("tokenizer.gd")


class CategoryTuple:
	var category_name: String
	var category_id: String

	func _init(category_name: String, category_id: String) -> void:
		self.category_name = category_name
		self.category_id = category_id


## Generates a .gd file that allows for easier access
## of categories and subcategories of the data
static func regenerate_category_id_file(root_categories: Array[PandoraCategory]) -> void:
	var root_category_tuples: Array[CategoryTuple] = []
	# { parent: [CategoryTuple] }
	var subcategory_tuples = {}

	for category in root_categories:
		root_category_tuples.append(
			CategoryTuple.new(category.get_entity_name(), category.get_entity_id())
		)
		generate_sub_category_tuples(
			category.get_entity_name(), category._children, subcategory_tuples
		)

	generate_category_id_file(root_category_tuples, subcategory_tuples)


static func generate_sub_category_tuples(
	parent_category: String, entities: Array[PandoraEntity], subcategory_tuples: Dictionary
) -> void:
	var category_tuples: Array[CategoryTuple] = []
	subcategory_tuples[parent_category] = category_tuples

	for entity in entities:
		if entity is PandoraCategory:
			var entity_name = entity.get_entity_name()

			subcategory_tuples[parent_category].append(
				CategoryTuple.new(entity_name, entity.get_entity_id())
			)

			# If we already have an existing category name, we need to rename it with the parent category
			if subcategory_tuples.has(entity_name):
				entity_name = "%s_%s" % [parent_category, entity_name]

			generate_sub_category_tuples(entity_name, entity._children, subcategory_tuples)


static func generate_category_id_file(
	root_category_tuples: Array[CategoryTuple], subcategory_tuples: Dictionary
) -> void:
	var file_path = "res://pandora/categories.gd"
	if not DirAccess.dir_exists_absolute("res://pandora"):
		DirAccess.make_dir_absolute("res://pandora")

	var file_access = FileAccess.open(file_path, FileAccess.WRITE)
	file_access.store_line("# Do not modify! Auto-generated file.")
	file_access.store_line("class_name PandoraCategories\n\n")

	# Per GDScript style guide we put consts at the top of the file so we do the root_category_tuples first
	for category_tuple in root_category_tuples:
		var line = (
			'const %s = "%s"'
			% [
				Tokenizer.tokenize(category_tuple.category_name),
				category_tuple.category_id
			]
		)
		file_access.store_line(line)

	file_access.store_line("\n")

	# We then do all the inline classes
	for parent_category in subcategory_tuples:
		if subcategory_tuples[parent_category].size() == 0:
			continue

		var line = "class %sCategories:" % parent_category.to_pascal_case()
		file_access.store_line(line)

		for category_tuple in subcategory_tuples[parent_category]:
			line = (
				'	const %s = "%s"'
				% [
					Tokenizer.tokenize(category_tuple.category_name),
					category_tuple.category_id
				]
			)
			file_access.store_line(line)
		file_access.store_line("\n")

	file_access.close()
