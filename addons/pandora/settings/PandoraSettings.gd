@tool
extends Node


var _static_backend:PandoraDataBackend = PandoraJsonDataBackend.new("res://pandora")
var _dynamic_backend:PandoraDataBackend = PandoraJsonDataBackend.new("user://pandora")


func get_static_backend() -> PandoraDataBackend:
	return _static_backend
	
	
func get_dynamic_backend() -> PandoraDataBackend:
	return _dynamic_backend


func get_static_cache_size() -> int:
	return 999
	

func get_dynamic_cache_size() -> int:
	return 999
