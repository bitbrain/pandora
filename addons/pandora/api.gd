@tool
extends Node


signal data_loaded
signal entity_added(entity:PandoraEntity)


var _context_manager:PandoraContextManager
var _entity_backend:PandoraEntityBackend
var _entity_instance_backend:PandoraEntityInstanceBackend
var _settings:PandoraSettings


var _loaded = false
var _defer_save = false
var _saving = false

	
func _enter_tree() -> void:
	self._settings = PandoraSettings.new()
	self._context_manager = PandoraContextManager.new()
	self._entity_backend = PandoraEntityBackend.new()
	self._entity_instance_backend = PandoraEntityInstanceBackend.new()
	
	self._entity_backend.entity_added.connect(func(entity): entity_added.emit(entity))
	
	load_data()


func _exit_tree() -> void:
	_clear()


func get_object_storage() -> PandoraDataStorage:
	return _settings.get_object_storage()
	

func get_instance_storage() -> PandoraDataStorage:
	return _settings.get_instance_storage()


func get_context_id() -> String:
	return _context_manager.get_context_id()
	
	
func set_context_id(context_id:String) -> void:
	_context_manager.set_context_id(context_id)
	
	
func create_entity(name:String, category:PandoraCategory) -> PandoraEntity:
	return _entity_backend.create_entity(name, category)


func create_category(name:String, parent_category:PandoraCategory = null) -> PandoraCategory:
	return _entity_backend.create_category(name, parent_category)
	
	
func create_property(on_category:PandoraCategory, name:String, default_value:Variant) -> PandoraProperty:
	return _entity_backend.create_property(on_category, name, default_value)
	
	
func get_entity(entity_id:String) -> PandoraEntity:
	return _entity_backend.get_entity(entity_id)
	
	
func get_category(category_id:String) -> PandoraCategory:
	return _entity_backend.get_category(category_id)
	
	
func get_property(property_id:String) -> PandoraProperty:
	return _entity_backend.get_property(property_id)
	
	
func get_all_categories() -> Array[PandoraEntity]:
	return _entity_backend.get_all_categories()
	
func get_all_entities() -> Array[PandoraEntity]:
	return _entity_backend.get_all_entities()
	

func create_entity_instance(of_entity:PandoraEntity) -> PandoraEntityInstance:
	return _entity_instance_backend.create_entity_instance(of_entity)
	
	
func get_entity_instance(instance_id:String) -> PandoraEntityInstance:
	return _entity_instance_backend.get_entity_instance(instance_id)


func delete_entity_instance(entity_instance_id:String) -> bool:
	return _entity_instance_backend.delete_entity_instance(entity_instance_id)


func load_data_async() -> void:
	var thread = Thread.new()
	if thread.start(load_data) != 0:
		push_error("Unable to load Pandora data in async mode.")

	
func load_data() -> void:
	if _loaded:
		print("Skipping loading data - loaded already!")
		data_loaded.emit()
		return
	_load_object_data()
	if not Engine.is_editor_hint():
		_load_instance_data()
	_loaded = true
	data_loaded.emit()
	
	
func save_data_async() -> Thread:
	var thread = Thread.new()
	if thread.start(save_data) != 0:
		push_error("Unable to save Pandora data in async mode.")
	return thread


func save_data() -> void:
	if Engine.is_editor_hint():
		_save_object_data()
	else:
		_save_instance_data()
	_saving = false

		
func save_data_deferred() -> void:
	_defer_save = true
		
		
func is_loaded() -> bool:
	return _loaded


func _load_object_data() -> void:
	var all_object_data = get_object_storage().get_all_data(_context_manager.get_context_id())
	if all_object_data.has("_entity_data"):
		_entity_backend.load_data(all_object_data["_entity_data"])
	
	
func _load_instance_data() -> void:
	var all_instance_data = get_instance_storage().get_all_data(_context_manager.get_context_id())
	if all_instance_data.has("_entity_instance_data"):
		_entity_instance_backend.load_data(all_instance_data["_entity_instance_data"])


func _save_object_data() -> void:
	var all_object_data = {
			"_entity_data": _entity_backend.save_data()
		}
	get_object_storage().store_all_data(all_object_data, _context_manager.get_context_id())
		
		
func _save_instance_data() -> void:
	var all_instance_data = {
			"_entity_instance_data": _entity_instance_backend.save_data()
		}
	get_instance_storage().store_all_data(all_instance_data, _context_manager.get_context_id())


# used for testing only and shutting down the addon
func _clear() -> void:
	_entity_backend._clear()
	_entity_instance_backend._clear()
	_loaded = false
	
	
func _process(delta: float) -> void:
	if _defer_save and not _saving:
		_defer_save = false
		_saving = true
		save_data_async()
