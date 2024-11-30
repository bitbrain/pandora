@tool
extends Node

const EntityIdFileGenerator = preload("res://addons/pandora/util/entity_id_file_generator.gd")
const CategoryIdFileGenerator = preload("res://addons/pandora/util/category_id_file_generator.gd")
const ScriptUtil = preload("res://addons/pandora/util/script_util.gd")

signal data_loaded
signal data_loaded_failure
signal entity_added(entity: PandoraEntity)
signal import_success(imported_count: int)
signal import_failed(reason: String)
signal import_calculation_ended(import_info: Dictionary)
signal import_calculation_failed(reason: String)
signal import_progress

var _context_manager: PandoraContextManager
var _storage: PandoraDataStorage
var _id_generator: PandoraIDGenerator
var _entity_backend: PandoraEntityBackend

var _loaded = false
var _backend_load_state: PandoraEntityBackend.LoadState = PandoraEntityBackend.LoadState.NOT_LOADED


func _enter_tree() -> void:
	self._storage = PandoraJsonDataStorage.new("res://")
	self._context_manager = PandoraContextManager.new()
	self._id_generator = PandoraIDGenerator.new()
	self._entity_backend = PandoraEntityBackend.new(_id_generator)
	self._entity_backend.entity_added.connect(func(entity): entity_added.emit(entity))
	self._entity_backend.import_progress.connect(func(): import_progress.emit())
	load_data()


func _exit_tree() -> void:
	_clear()
	_entity_backend = null
	_context_manager = null
	_id_generator = null
	_storage = null


func get_context_id() -> String:
	return _context_manager.get_context_id()


func set_context_id(context_id: String) -> void:
	_context_manager.set_context_id(context_id)


func create_entity(name: String, category: PandoraCategory) -> PandoraEntity:
	return _entity_backend.create_entity(name, category)


func create_category(name: String, parent_category: PandoraCategory = null) -> PandoraCategory:
	return _entity_backend.create_category(name, parent_category)


func create_property(on_category: PandoraCategory, name: String, type: String) -> PandoraProperty:
	return _entity_backend.create_property(on_category, name, type)


func regenerate_all_ids() -> void:
	_entity_backend.regenerate_all_ids()


func regenerate_entity_id(entity: PandoraEntity) -> void:
	_entity_backend.regenerate_entity_id(entity)


func regenerate_category_id(category: PandoraCategory) -> void:
	_entity_backend.regenerate_category_id(category)


func regenerate_property_id(property: PandoraProperty) -> void:
	_entity_backend.regenerate_property_id(property)


func delete_category(category: PandoraCategory) -> void:
	_entity_backend.delete_category(category)


func delete_entity(entity: PandoraEntity) -> void:
	_entity_backend.delete_entity(entity)


func move_entity(
	source: PandoraEntity, target: PandoraEntity, drop_section: PandoraEntityBackend.DropSection
) -> void:
	_entity_backend.move_entity(source, target, drop_section)


func get_entity(entity_id: String) -> PandoraEntity:
	return _entity_backend.get_entity(entity_id)


func get_category(category_id: String) -> PandoraCategory:
	return _entity_backend.get_category(category_id)


func get_property(property_id: String) -> PandoraProperty:
	return _entity_backend.get_property(property_id)


func get_all_roots() -> Array[PandoraCategory]:
	return _entity_backend.get_all_roots()


func get_all_categories(
	filter: PandoraCategory = null, sort: Callable = func(a, b): return false
) -> Array[PandoraEntity]:
	return _entity_backend.get_all_categories(filter, sort)


func get_all_entities(
	filter: PandoraCategory = null, sort: Callable = func(a, b): return false
) -> Array[PandoraEntity]:
	return _entity_backend.get_all_entities(filter, sort)


func check_if_properties_will_change_on_move(
	source: PandoraEntity, target: PandoraEntity, drop_section: PandoraEntityBackend.DropSection
) -> bool:
	return _entity_backend.check_if_properties_will_change_on_move(source, target, drop_section)


func load_data_async() -> void:
	var thread = Thread.new()
	if thread.start(load_data) != 0:
		push_error("Unable to load Pandora data in async mode.")


func load_data() -> void:
	if _loaded:
		print("Skipping loading data - loaded already!")
		data_loaded.emit()
		return
	var all_object_data = _storage.get_all_data(_context_manager.get_context_id())
	if all_object_data.has("_entity_data") and not all_object_data.is_empty():
		_backend_load_state = _entity_backend.load_data(all_object_data["_entity_data"])
	if all_object_data.has("_id_generator") and not all_object_data.is_empty():
		_id_generator.load_data(all_object_data["_id_generator"])
	if all_object_data.is_empty() or _backend_load_state == PandoraEntityBackend.LoadState.LOADED:
		_backend_load_state = PandoraEntityBackend.LoadState.LOADED
		_loaded = true
		data_loaded.emit()
	else:
		data_loaded_failure.emit()


func save_data() -> void:
	if not _loaded:
		push_warning("Pandora: Skip saving data - data not loaded yet.")
		return
	var all_object_data = {
		"_entity_data": _entity_backend.save_data(),
		"_id_generator": _id_generator.save_data(),
	}
	_storage.store_all_data(all_object_data, _context_manager.get_context_id())

	EntityIdFileGenerator.regenerate_id_files(get_all_roots())
	CategoryIdFileGenerator.regenerate_category_id_file(get_all_roots())


func calculate_import_data(path: String) -> int:
	var imported_data = _storage.load_from_file(path)
	var total_items = 0
	if not imported_data.has("_entity_data"):
		import_calculation_failed.emit("Provided file is invalid or is corrupted.")
	else:
		total_items = (
			imported_data["_entity_data"]["_categories"].size()
			+ imported_data["_entity_data"]["_entities"].size()
			+ imported_data["_entity_data"]["_properties"].size()
		)
		if total_items == 0:
			import_calculation_failed.emit("Provided file is empty.")
		else:
			(
				import_calculation_ended
				. emit(
					{
						"total_categories": imported_data["_entity_data"]["_categories"].size(),
						"total_entities": imported_data["_entity_data"]["_entities"].size(),
						"total_properties": imported_data["_entity_data"]["_properties"].size(),
						"path": path,
					}
				)
			)
	return total_items


func import_data(path: String) -> int:
	var imported_data = _storage.load_from_file(path)
	if not imported_data.has("_entity_data"):
		import_failed.emit("Provided file is invalid or is corrupted.")
		return 0

	var imported_count = _entity_backend.import_data(imported_data["_entity_data"])
	if imported_count == -1:
		import_failed.emit("No data found in file.")
		return 0

	import_success.emit(imported_count)

	return imported_count


func is_loaded() -> bool:
	return _loaded


func serialize(instance: PandoraEntity) -> Dictionary:
	if instance is PandoraCategory:
		push_warning("Cannot serialize a category!")
		return {}
	if not instance.is_instance():
		var new_instance = instance.instantiate()
		return new_instance.save_data()
	return instance.save_data()


func deserialize(data: Dictionary) -> PandoraEntity:
	if not _loaded:
		push_warning("Pandora - cannot deserialize: data not initialized yet.")
		return null
	if not data.has("_instance_id"):
		push_error(
			"Unable to deserialize data! Not an instance! Call PandoraEntity.instantiate() to create instances."
		)
		return
	var entity = Pandora.get_entity(data["_id"])
	if not entity:
		return
	var instance = ScriptUtil.create_entity_from_script(entity.get_script_path(), "", "", "", "")
	instance.load_data(data)
	return instance


# used for testing only and shutting down the addon
func _clear() -> void:
	_entity_backend._clear()
	_id_generator.clear()
	_loaded = false
	_backend_load_state = PandoraEntityBackend.LoadState.NOT_LOADED
