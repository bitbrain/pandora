## Generates a .gd file that allows for easier access
## of entities
static func regenerate_entity_id_file(entities:Array[PandoraEntity], file:String) -> void:
	var file_path = "res://pandora/" + file
	if not DirAccess.dir_exists_absolute("res://pandora"):
		DirAccess.make_dir_absolute("res://pandora")
		
	var file_access = FileAccess.open(file_path, FileAccess.WRITE)
	file_access.store_line("# Do not modify! Auto-generated file.")
	file_access.store_line("class_name EntityIds\n\n")
	
	# avoid duplicate constants by counting how often each name has been used
	var name_usages = {}
	
	for entity in entities:
		if not name_usages.has(entity.get_entity_name()):
			name_usages[entity.get_entity_name()] = 0
		var entity_name = entity.get_entity_name() if name_usages[entity.get_entity_name()] == 0 else entity.get_entity_name() + str(name_usages[entity.get_entity_name()])
		file_access.store_line("const " + entity_name.to_upper().replace(" ", "_").replace("-", "_") + " = " + "\"" + entity.get_entity_id() + "\"")
		name_usages[entity.get_entity_name()] += 1
	file_access.close()
