extends Node

const PandoraEntityScript = preload("res://addons/pandora/model/entity.gd")


static func create_entity_from_script(
	path: String, id: String, name: String, icon_path: String, category_id: String
):
	var clazz = _get_entity_class(path)
	var new_method = _find_first_method_of_script(clazz, "init_entity")
	if not new_method.has("args"):
		push_warning("ERROR - Pandora is unable to correctly resolve new() method.")
		var entity = PandoraEntityScript.new()
		entity.init_entity(id, name, icon_path, category_id)
		return entity
	var expected_method = _find_first_method_of_script(PandoraEntityScript, "init_entity")
	if new_method["args"].size() != expected_method["args"].size():
		push_warning(
			(
				"init_entity() method has incorrect signature! Requires "
				+ str(expected_method["args"].size())
				+ " arguments - defaulting to PandoraEntity instead."
			)
		)
		var entity = PandoraEntityScript.new()
		entity.init_entity(id, name, icon_path, category_id)
		return entity

	var entity = clazz.new()
	if not entity is PandoraEntity:
		push_warning(
			"Script '" + path + "' must extend PandoraEntity - defaulting to PandoraEntity instead."
		)
		entity = PandoraEntityScript.new()

	entity.init_entity(id, name, icon_path, category_id)
	return entity


static func _get_entity_class(path: String) -> GDScript:
	var EntityClass = load(path)
	if EntityClass == null or not EntityClass.can_instantiate():
		push_warning("Unable to find " + path + " - defaulting to PandoraEntity instead.")
		EntityClass = PandoraEntityScript
	return EntityClass


## searches for the first occurence of the method.
## methods can occur multiple times in the order of inheritance.
static func _find_first_method_of_script(script: GDScript, method_name: String) -> Dictionary:
	for method in script.get_script_method_list():
		if method.name == method_name:
			return method
	return {}
