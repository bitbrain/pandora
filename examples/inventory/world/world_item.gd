@tool
extends Node2D


@export var item:PandoraEntity:
	set(i):
		item = i
		if item_instance == null or not item_instance.type_of(i):
			_instantiate.call_deferred()


@onready var sprite = $Sprite2D


var item_instance:Item:
	set(ii):
		item_instance = ii
		if sprite != null:
			sprite.texture = item_instance.get_icon()


func _ready() -> void:
	if item and not item_instance:
		_instantiate.call_deferred()
		
		
func _instantiate() -> void:
	item_instance = item.instantiate()
