## Generates a .gd file that allows for easier access
## of entities
static func regenerate_id_files(root_categories: Array[PandoraCategory]) -> void:
	# class name  -> Array[Entity]
	var class_to_entity_map = {}
	for category in root_categories:
		regenerate_id_files_for_category(category, class_to_entity_map)

	for entity_class in class_to_entity_map:
		regenerate_entity_id_file(entity_class, class_to_entity_map[entity_class])


static func regenerate_id_files_for_category(
	category: PandoraCategory, class_to_entity_map: Dictionary
) -> void:
	for child in category._children:
		if child is PandoraCategory:
			regenerate_id_files_for_category(child as PandoraCategory, class_to_entity_map)
		else:
			if category.is_generate_ids():
				if not class_to_entity_map.has(category.get_id_generation_class()):
					var entities: Array[PandoraEntity] = []
					class_to_entity_map[category.get_id_generation_class()] = entities
				class_to_entity_map[category.get_id_generation_class()].append(child)


static func regenerate_entity_id_file(
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
		if not name_usages.has(entity.get_entity_name()):
			name_usages[entity.get_entity_name()] = 0
		var entity_name = (
			entity.get_entity_name()
			if name_usages[entity.get_entity_name()] == 0
			else entity.get_entity_name() + str(name_usages[entity.get_entity_name()])
		)
		file_access.store_line(
			(
				"const "
				+ entity_name.to_upper().replace(" ", "_")
				+ " = "
				+ '"'
				+ entity.get_entity_id()
				+ '"'
			)
		)
		name_usages[entity.get_entity_name()] += 1
	file_access.close()
