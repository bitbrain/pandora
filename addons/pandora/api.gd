@tool
extends Node


const EntityIdFileGenerator = preload("res://addons/pandora/util/entity_id_file_generator.gd")
const ScriptUtil = preload("res://addons/pandora/util/script_util.gd")


signal data_loaded
signal data_loaded_failure
signal entity_added(entity:PandoraEntity)


var _context_manager:PandoraContextManager
var _storage:PandoraJsonDataStorage
var _id_generator: PandoraIDGenerator
var _entity_backend:PandoraEntityBackend


var _loaded = false
var _backend_load_state:PandoraEntityBackend.LoadState = PandoraEntityBackend.LoadState.NOT_LOADED


func _enter_tree() -> void:
	self._storage = PandoraJsonDataStorage.new("res://")
	self._context_manager = PandoraContextManager.new()
	
	var id_type := PandoraSettings.get_id_type()
	if id_type == PandoraSettings.ID_TYPE.Sequential:
		self._id_generator = PandoraSequentialIDGenerator.new()
	elif id_type == PandoraSettings.ID_TYPE.NanoID:
		self._id_generator = PandoraNanoIDGenerator.new(10)
	else:
		push_error("unknown is type: %s" % id_type)
		self._id_generator = PandoraSequentialIDGenerator.new()
	
	self._entity_backend = PandoraEntityBackend.new(_id_generator)
	self._entity_backend.entity_added.connect(func(entity): entity_added.emit(entity))
	load_data()


func _exit_tree() -> void:
	_clear()
	_entity_backend = null
	_context_manager = null
	_id_generator = null
	_storage = null


func get_context_id() -> String:
	return _context_manager.get_context_id()


func set_context_id(context_id:String) -> void:
	_context_manager.set_context_id(context_id)


func create_entity(name:String, category:PandoraCategory) -> PandoraEntity:
	return _entity_backend.create_entity(name, category)


func create_category(name:String, parent_category:PandoraCategory = null) -> PandoraCategory:
	return _entity_backend.create_category(name, parent_category)


func create_property(on_category:PandoraCategory, name:String, type:String) -> PandoraProperty:
	return _entity_backend.create_property(on_category, name, type)


func regenerate_all_ids() -> void:
	_entity_backend.regenerate_all_ids()


func regenerate_entity_id(entity: PandoraEntity) -> void:
	_entity_backend.regenerate_entity_id(entity)


func regenerate_category_id(category: PandoraCategory) -> void:
	_entity_backend.regenerate_category_id(category)


func regenerate_property_id(property: PandoraProperty) -> void:
	_entity_backend.regenerate_property_id(property)


func delete_category(category:PandoraCategory) -> void:
	_entity_backend.delete_category(category)


func delete_entity(entity:PandoraEntity) -> void:
	_entity_backend.delete_entity(entity)


func get_entity(entity_id:String) -> PandoraEntity:
	return _entity_backend.get_entity(entity_id)


func get_category(category_id:String) -> PandoraCategory:
	return _entity_backend.get_category(category_id)


func get_property(property_id:String) -> PandoraProperty:
	return _entity_backend.get_property(property_id)


func get_all_roots() -> Array[PandoraCategory]:
	return _entity_backend.get_all_roots()


func get_all_categories(filter:PandoraCategory = null, sort:Callable = func(a,b): return false) -> Array[PandoraEntity]:
	return _entity_backend.get_all_categories(filter, sort)


func get_all_entities(filter:PandoraCategory = null, sort:Callable = func(a,b): return false) -> Array[PandoraEntity]:
	return _entity_backend.get_all_entities(filter, sort)


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
	if (all_object_data.has("_id_generator") and not all_object_data.is_empty()
			and _id_generator is PandoraSequentialIDGenerator):
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
		"_entity_data": _entity_backend.save_data()
	}
	if _id_generator is PandoraSequentialIDGenerator:
		all_object_data["_id_generator"] = _id_generator.save_data()
	_storage.store_all_data(all_object_data, _context_manager.get_context_id())

	EntityIdFileGenerator.regenerate_id_files(get_all_roots())


func is_loaded() -> bool:
	return _loaded
	
	
func serialize(instance:PandoraEntity) -> Dictionary:
	if instance is PandoraCategory:
		push_warning("Cannot serialize a category!")
		return {}
	if not instance.is_instance():
		var new_instance = instance.instantiate()
		return new_instance.save_data()
	return instance.save_data()
	
	
func deserialize(data:Dictionary) -> PandoraEntity:
	if not _loaded:
		push_warning("Pandora - cannot deserialize: data not initialized yet.")
		return null
	if not data.has("_instanced_from_id"):
		push_error("Unable to deserialize data! Not an instance! Call PandoraEntity.instantiate() to create instances.")
		return
	var entity = Pandora.get_entity(data["_instanced_from_id"])
	if not entity:
		return
	var instance = ScriptUtil.create_entity_from_script(entity.get_script_path(), "", "", "", "")
	instance.load_data(data)
	return instance


# used for testing only and shutting down the addon
func _clear() -> void:
	_entity_backend._clear()
	_loaded = false
	_backend_load_state = PandoraEntityBackend.LoadState.NOT_LOADED
