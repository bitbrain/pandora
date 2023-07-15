class_name PandoraSettings extends RefCounted


var _object_storage:PandoraDataStorage
var _instance_storage:PandoraDataStorage


func _init() -> void:
	self._object_storage = PandoraJsonDataStorage.new("res://")
	self._instance_storage = PandoraJsonDataStorage.new("user://")
	

func get_object_storage() -> PandoraDataStorage:
	return _object_storage
	
	
func get_instance_storage() -> PandoraDataStorage:
	return _instance_storage
