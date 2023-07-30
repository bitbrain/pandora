@tool
extends Node2D


signal pick_up(item_instance:ItemInstance)


@export var item:PandoraEntity:
	set(i):
		item = i
		if item_instance == null or not item_instance.type_of(i):
			_instantiate_instance.call_deferred()


@onready var sprite = $Sprite2D
@onready var world_item_body = $WorldItemBody


var item_instance:ItemInstance:
	set(ii):
		item_instance = ii
		if item == null:
			_instantiate_entity.call_deferred()
		if sprite != null:
			sprite.texture = item_instance.get_icon()


func _ready() -> void:
	if item and not item_instance:
		_instantiate_instance.call_deferred()
	world_item_body.clicked.connect(_pick_up)
		
		
func _instantiate_instance() -> void:
	item_instance = item.instantiate()
	
	
func _instantiate_entity() -> void:
	item = item_instance.get_entity()
	
	
func _pick_up() -> void:
	pick_up.emit(item_instance)
