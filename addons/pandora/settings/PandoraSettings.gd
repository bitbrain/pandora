@tool
extends Node


var _object_storage:PandoraDataStorage = PandoraJsonDataStorage.new("res://")
var _instance_storage:PandoraDataStorage = PandoraJsonDataStorage.new("user://")


func get_object_storage() -> PandoraDataStorage:
	return _object_storage
	
	
func get_instance_storage() -> PandoraDataStorage:
	return _instance_storage
