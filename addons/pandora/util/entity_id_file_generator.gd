const Tokenizer = preload("tokenizer.gd")


## Generates a .gd file that allows for easier access
## of entities
static func regenerate_id_files(root_categories: Array[PandoraCategory]) -> void:
	var class_to_entity_map = generate_class_to_entity_map(root_categories)

	for entity_class in class_to_entity_map:
		generate_entity_id_file(entity_class, class_to_entity_map[entity_class])


static func generate_class_to_entity_map(
	root_categories: Array[PandoraCategory]
) -> Dictionary:
	var class_to_entity_map = {}
	for category in root_categories:
		_process_category_for_id_files(category, class_to_entity_map)
	return class_to_entity_map


static func _process_category_for_id_files(
	category: PandoraCategory, class_to_entity_map: Dictionary
) -> void:
	for child in category._children:
		if child is PandoraCategory:
			_process_category_for_id_files(child as PandoraCategory, class_to_entity_map)
		else:
			if category.is_generate_ids():
				var classname = category.get_id_generation_class()
				if not class_to_entity_map.has(classname):
					var new_array:Array[PandoraEntity] = []
					class_to_entity_map[classname] = new_array
				class_to_entity_map[classname].append(child as PandoraEntity)


static func generate_entity_id_file(
	entity_class_name: String, entities: Array[PandoraEntity]
) -> void:
	var file_path = "res://pandora/" + entity_class_name.to_snake_case() + ".gd"
	if not DirAccess.dir_exists_absolute("res://pandora"):
		DirAccess.make_dir_absolute("res://pandora")

	var file_access = FileAccess.open(file_path, FileAccess.WRITE)
	file_access.store_line("# Do not modify! Auto-generated file.")
	file_access.store_line("class_name " + entity_class_name + "\n\n")

	# avoid duplicate constants by counting how often each name has been used
	var name_usages = {}

	for entity in entities:
		var entity_name = entity.get_entity_name()
		if not name_usages.has(entity_name):
			name_usages[entity_name] = 0
		else:
			name_usages[entity_name] += 1
			entity_name += str(name_usages[entity_name])

		file_access.store_line(
			"const " + Tokenizer.tokenize(entity_name) + ' = "' + entity.get_entity_id() + '"'
		)
	file_access.close()
