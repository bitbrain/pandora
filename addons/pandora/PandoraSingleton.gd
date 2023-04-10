@tool
extends Node

@onready var _item_server:PandoraItemServer = $PandoraItemServer

func get_item_server() -> PandoraItemServer:
	return _item_server

func get_data_backend() -> PandoraDataBackend:
	return PandoraSettings.get_current_backend()
