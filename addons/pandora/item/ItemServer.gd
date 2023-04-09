class_name PandoraItemServer extends Node

# TODO lookup current backend dynamically

func get_item_instance_by_id(id:String) -> ItemInstance:
	return null
	

func get_item_by_id(id:String) -> Item:
	return null


func get_inventory_by_id(id:String) -> Inventory:
	return null
	
	
func get_category_by_id(id:String) -> ItemCategory:
	return null


func create_item_instance(item:Item) -> ItemInstance:
	return null


func create_item_category(category:ItemCategory) -> ItemCategory:
	return null


func create_inventory() -> Inventory:
	return null


func save_item_instance(item_instance:ItemInstance) -> ItemInstance:
	return item_instance


func save_item(item:Item) -> Item:
	return item


func save_item_category(item:ItemCategory) -> ItemCategory:
	return item
