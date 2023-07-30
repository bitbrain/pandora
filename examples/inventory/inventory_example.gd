class_name WorldItem extends Node2D


@onready var world_items = %WorldItems
@onready var inventory = %Inventory


func _ready():
	inventory.item_removed.connect(_drop)
	for child in world_items.get_children():
		child.pick_up.connect(func(item): _pick_up(child, item))


func _pick_up(world_item, item_instance:ItemInstance) -> void:
	world_item.queue_free()
	inventory.add_item(item_instance)
	
	
func _drop(item_instance:ItemInstance, index:int) -> void:
	var world_item = WorldItem.instantiate()
	world_item.item_instance = item_instance
	world_item.position.x = randf_range(0, 500)
	world_item.position.y = randf_range(0, 500)
	world_items.add_child(world_item)
