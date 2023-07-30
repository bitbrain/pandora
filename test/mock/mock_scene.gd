extends Node2D


@export var entity:PandoraEntity


var _instance:PandoraEntityInstance


func _ready():
	_instance = entity.instantiate()


func get_entity_instance() -> PandoraEntityInstance:
	return _instance
