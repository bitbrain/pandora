@tool
extends Node


const EntityIdFileGenerator = preload("res://addons/pandora/util/entity_id_file_generator.gd")


signal data_loaded
signal entity_added(entity:PandoraEntity)


var _context_manager:PandoraContextManager
var _storage:PandoraJsonDataStorage
var _id_generator:PandoraIdGenerator
var _entity_backend:PandoraEntityBackend


var _loaded = false

	
func _enter_tree() -> void:
	self._storage = PandoraJsonDataStorage.new("res://")
	self._context_manager = PandoraContextManager.new()
	self._id_generator = PandoraIdGenerator.new()
	self._entity_backend = PandoraEntityBackend.new(_id_generator)
	self._entity_backend.entity_added.connect(func(entity): entity_added.emit(entity))
	load_data()


func _exit_tree() -> void:
	_clear()


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
	if all_object_data.has("_entity_data"):
		_entity_backend.load_data(all_object_data["_entity_data"])
	if all_object_data.has("_id_generator"):
		_id_generator.load_data(all_object_data["_id_generator"])
	_loaded = true
	data_loaded.emit()


func save_data() -> void:
	var all_object_data = {
			"_entity_data": _entity_backend.save_data(),
			"_id_generator": _id_generator.save_data()
		}
	_storage.store_all_data(all_object_data, _context_manager.get_context_id())

	EntityIdFileGenerator.regenerate_id_files(get_all_roots())

		
func is_loaded() -> bool:
	return _loaded
	
	
func serialize(instance:PandoraEntityInstance) -> Dictionary:
	return instance.save_data()
	
	
func deserialize(data:Dictionary) -> PandoraEntityInstance:
	if not data.has("_entity_id"):
		push_error("Unable to deserialize data! Invalid PandoraEntityInstance format.")
		return
	var entity = Pandora.get_entity(data["_entity_id"])
	if not entity:
		return
	var InstanceClass = load(entity.get_instance_script_path())
	if not InstanceClass:
		push_error("Unable to deserialize data! Invalid instance script.")
		return
	var instance = InstanceClass.new("", [])
	instance._load_data(data)
	return instance


# used for testing only and shutting down the addon
func _clear() -> void:
	_entity_backend._clear()
	_id_generator.clear()
	_loaded = false
