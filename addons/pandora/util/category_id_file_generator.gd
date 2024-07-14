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
	var root_category_tuples: Array[CategoryTuple] = generate_parent_category_tuples(root_categories)
	var subcategory_tuples: Dictionary = generate_sub_category_tuples(root_categories)
	generate_category_id_file(root_category_tuples, subcategory_tuples)


static func generate_parent_category_tuples(root_categories: Array[PandoraCategory]) -> Array[CategoryTuple]:
	var root_category_tuples: Array[CategoryTuple] = []
	for category in root_categories:
		root_category_tuples.append(CategoryTuple.new(category.get_entity_name(), category.get_entity_id()))
	return root_category_tuples


static func generate_sub_category_tuples(root_categories: Array[PandoraCategory]) -> Dictionary:
	var subcategory_tuples = {}
	for category in root_categories:
		_process_sub_category_tuples(category.get_entity_name(), category._children, subcategory_tuples)
	return subcategory_tuples


static func _process_sub_category_tuples(
	parent_category: String, entities: Array[PandoraEntity], subcategory_tuples: Dictionary) -> void:
	var local_subcategories = []

	for entity in entities:
		if entity is PandoraCategory:
			var entity_name = entity.get_entity_name()
			var entity_id = entity.get_entity_id()
			var category_tuple = CategoryTuple.new(entity_name, entity_id)
			var new_key = parent_category + "_" + entity_name

			_process_sub_category_tuples(new_key, entity._children, subcategory_tuples)

			# Add current category to the local list if it's a leaf or has children
			if not subcategory_tuples.has(new_key) or subcategory_tuples[new_key].size() == 0:
				subcategory_tuples.erase(new_key)  # Remove if empty
			local_subcategories.append(category_tuple)

	if local_subcategories.size() > 0:
		subcategory_tuples[parent_category] = local_subcategories



static func generate_category_id_file(
	root_category_tuples: Array[CategoryTuple], subcategory_tuples: Dictionary) -> void:
	var file_path = "res://pandora/categories.gd"
	if not DirAccess.dir_exists_absolute("res://pandora"):
		DirAccess.make_dir_absolute("res://pandora")

	var file_access = FileAccess.open(file_path, FileAccess.WRITE)
	file_access.store_line("# Do not modify! Auto-generated file.")
	file_access.store_line("class_name PandoraCategories\n\n")

	for category_tuple in root_category_tuples:
		var line = 'const %s = "%s"' % [Tokenizer.tokenize(category_tuple.category_name), category_tuple.category_id]
		file_access.store_line(line)

	file_access.store_line("\n")
	for parent_category in subcategory_tuples:
		if subcategory_tuples[parent_category].size() == 0:
			continue
		var line = "class %sCategories:" % parent_category.to_pascal_case()
		file_access.store_line(line)
		for category_tuple in subcategory_tuples[parent_category]:
			line = '	const %s = "%s"' % [Tokenizer.tokenize(category_tuple.category_name), category_tuple.category_id]
			file_access.store_line(line)
		file_access.store_line("\n")
	file_access.close()
