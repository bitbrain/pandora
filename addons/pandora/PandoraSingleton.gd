@tool
extends Node


@onready var _item_server:PandoraItemServer = $PandoraItemServer
@onready var _context_manager:PandoraContextManager = $PandoraContextManager


var static_cache : PandoraCache
var dynamic_cache : PandoraCache
var static_data_sync : PandoraDataSyncer
var dynamic_data_sync : PandoraDataSyncer


func _ready() -> void:
	self.static_cache = PandoraLeastAccessedCache.new(PandoraSettings.get_static_cache_size())
	self.dynamic_cache = PandoraLeastAccessedCache.new(PandoraSettings.get_dynamic_cache_size())
	self.static_data_sync = PandoraDataSyncer.new(static_cache, PandoraSettings.get_static_backend())
	self.dynamic_data_sync = PandoraDataSyncer.new(dynamic_cache, PandoraSettings.get_dynamic_backend())
	
	_item_server.static_cache = self.static_cache
	_item_server.dynamic_cache = self.dynamic_cache


func get_item_server() -> PandoraItemServer:
	return _item_server


func get_data_backend() -> PandoraDataBackend:
	return PandoraSettings.get_current_backend()


func get_context_manager() -> PandoraContextManager:
	return _context_manager
	
	
func flush(data_type:String) -> void:
	dynamic_data_sync.flush(data_type)
	static_data_sync.flush(data_type)
	
	
func warm_up(data_type:String) -> void:
	dynamic_data_sync.warm_up(data_type)
	static_data_sync.warm_up(data_type)
