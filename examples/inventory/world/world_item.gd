@tool
extends Node2D


@export var item:PandoraEntity:
	set(i):
		item = i
		if item_instance == null or not item_instance.type_of(i):
			item_instance = item.instantiate()


@onready var sprite = $Sprite2D


var item_instance:ItemInstance:
	set(ii):
		item_instance = ii
		if sprite != null:
			sprite.texture = item_instance.get_icon()


func _ready() -> void:
	if item and not item_instance:
		self.item_instance = item.instantiate()
