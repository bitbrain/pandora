extends Node


var _item_server:PandoraItemServer = $PandoraItemServer
var _backend:PandoraDataBackend


func get_item_server() -> PandoraItemServer:
	return _item_server


func get_data_backend() -> PandoraDataBackend:
	return _backend
