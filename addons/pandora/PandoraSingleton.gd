@tool
extends Node


@onready var _item_server:PandoraItemServer = $PandoraItemServer
@onready var _context_manager:PandoraContextManager = $PandoraContextManager


func get_item_server() -> PandoraItemServer:
	return _item_server


func get_data_backend() -> PandoraDataBackend:
	return PandoraSettings.get_current_backend()


func get_context_manager() -> PandoraContextManager:
	return _context_manager
