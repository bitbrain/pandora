@tool
extends Node

var _backend:PandoraDataBackend = PandoraJsonBackend.new()

func get_current_backend() -> PandoraDataBackend:
	return _backend
