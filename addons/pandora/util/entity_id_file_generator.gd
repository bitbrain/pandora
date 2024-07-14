const Tokenizer = preload("tokenizer.gd")

static func regenerate_id_files(root_categories: Array[PandoraCategory]) -> void:
	var class_to_entity_map = generate_class_to_entity_map(root_categories)
	for entity_class in class_to_entity_map:
		var file_content = generate_entity_id_file(entity_class, class_to_entity_map[entity_class])
		if not file_content.is_empty():
			_write_to_file(entity_class, file_content)

static func generate_class_to_entity_map(root_categories: Array[PandoraCategory]) -> Dictionary:
	var class_to_entity_map = {}
	for category in root_categories:
		_process_category_for_id_files(category, class_to_entity_map)

	# Remove empty entries from the map
	var keys_to_remove = []
	for key in class_to_entity_map.keys():
		if class_to_entity_map[key].size() == 0:
			keys_to_remove.append(key)
	for key in keys_to_remove:
		class_to_entity_map.erase(key)

	return class_to_entity_map

static func generate_entity_id_file(entity_class_name: String, entities: Array[PandoraEntity]) -> Array[String]:
	if entities.is_empty():
		return []
	var lines:Array[String] = ["# Do not modify! Auto-generated file.", "class_name " + entity_class_name + "\n\n"]
	var name_usages = {}
	for entity in entities:
		var entity_name = entity.get_entity_name()
		if not name_usages.has(entity_name):
			name_usages[entity_name] = 0
		else:
			name_usages[entity_name] += 1
			entity_name += str(name_usages[entity_name])
		lines.append("const " + Tokenizer.tokenize(entity_name) + ' = "' + entity.get_entity_id() + '"')
	return lines

static func _process_category_for_id_files(category: PandoraCategory, class_to_entity_map: Dictionary) -> void:
	var classname = category.get_id_generation_class()
	if not class_to_entity_map.has(classname):
		var empty:Array[PandoraEntity] = []
		class_to_entity_map[classname] = empty

	if category.is_generate_ids():
		for child in category._children:
			if not child is PandoraCategory:
				if not _entity_exists_in_map(class_to_entity_map[classname], child):
					class_to_entity_map[classname].append(child)
			else:
				_process_category_for_id_files(child as PandoraCategory, class_to_entity_map)

	for child in category._children:
		if child is PandoraCategory:
			var child_classname = child.get_id_generation_class()
			if class_to_entity_map.has(child_classname):
				for sub_entity in class_to_entity_map[child_classname]:
					if not _entity_exists_in_map(class_to_entity_map[classname], sub_entity):
						class_to_entity_map[classname].append(sub_entity)

static func _entity_exists_in_map(entity_list: Array[PandoraEntity], entity: PandoraEntity) -> bool:
	for e in entity_list:
		if e.get_entity_id() == entity.get_entity_id():
			return true
	return false

static func _write_to_file(entity_class_name: String, lines: Array[String]) -> void:
	var file_path = "res://pandora/" + entity_class_name.to_snake_case() + ".gd"
	if not DirAccess.dir_exists_absolute("res://pandora"):
		DirAccess.make_dir_absolute("res://pandora")

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		for line in lines:
			file.store_line(line)
		file.close()
	else:
		print("Failed to open file for writing: " + file_path)
