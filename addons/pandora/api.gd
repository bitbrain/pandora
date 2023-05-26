@tool
extends Node


signal data_loaded
signal entity_added(entity:PandoraEntity)


@onready var _context_manager:PandoraContextManager = $PandoraContextManager
@onready var _entity_backend:PandoraEntityBackend = PandoraEntityBackend.new()
@onready var _entity_instance_backend:PandoraEntityInstanceBackend = PandoraEntityInstanceBackend.new()


var _loaded = false


func _ready() -> void:
	_entity_backend.entity_added.connect(func(entity): entity_added.emit(entity))
	
	# initialise data the next frame so nodes get the chance
	# to connect to required signals!
	call_deferred("load_data")


func get_object_storage() -> PandoraDataStorage:
	return PandoraSettings.get_object_storage()
	

func get_instance_storage() -> PandoraDataStorage:
	return PandoraSettings.get_instance_storage()


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


func save_data() -> void:
	if Engine.is_editor_hint():
		_save_object_data()
	else:
		_save_instance_data()


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
