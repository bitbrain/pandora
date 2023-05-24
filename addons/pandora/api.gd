@tool
extends Node

signal data_loaded

@onready var _context_manager:PandoraContextManager = $PandoraContextManager
@onready var _item_backend:PandoraEntityBackend = PandoraEntityBackend.new()
@onready var _item_instance_backend:PandoraEntityInstanceBackend = PandoraEntityInstanceBackend.new()

var _loaded = false

func get_object_storage() -> PandoraDataStorage:
	return PandoraSettings.get_object_storage()
	

func get_instance_storage() -> PandoraDataStorage:
	return PandoraSettings.get_instance_storage()


func get_context_id() -> String:
	return _context_manager.get_context_id()
	
	
func set_context_id(context_id:String) -> void:
	_context_manager.set_context_id(context_id)
	
	
func get_item_backend() -> PandoraEntityBackend:
	return _item_backend
	
	
func get_item_instance_backend() -> PandoraEntityInstanceBackend:
	return _item_instance_backend


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
	if all_object_data.has("_items"):
		_item_backend.load_data(all_object_data["_items"])
	
	
func _load_instance_data() -> void:
	var all_instance_data = get_instance_storage().get_all_data(_context_manager.get_context_id())
	if all_instance_data.has("_item_instances"):
		_item_instance_backend.load_data(all_instance_data["_item_instances"])


func _save_object_data() -> void:
	var all_object_data = {
			"_items": _item_backend.save_data()
		}
	get_object_storage().store_all_data(all_object_data, _context_manager.get_context_id())
		
		
func _save_instance_data() -> void:
	var all_instance_data = {
			"_item_instances": _item_instance_backend.save_data()
		}
	get_instance_storage().store_all_data(all_instance_data, _context_manager.get_context_id())


# used for testing only and shutting down the addon
func _clear() -> void:
	_item_backend._clear()
	_item_instance_backend._clear()
	_loaded = false
