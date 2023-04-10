@tool
class_name PandoraItemServer extends Node


const UUID = preload("res://addons/pandora/utils/UUID.gd")


func get_item_instance_by_id(id:String) -> ItemInstance:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as ItemInstance
	else:
		return null
	

func get_item_by_id(id:String) -> Item:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as Item
	else:
		return null


func get_inventory_by_id(id:String) -> Inventory:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as Inventory
	else:
		return null
	
	
func get_category_by_id(id:String) -> ItemCategory:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as ItemCategory
	else:
		return null


func create_item(name:String) -> Item:
	var instance = Item.new()
	instance._id = "item-" + UUID.generate()
	instance.maximum_stack_size = -1 #infinite
	instance.name = name
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func create_item_instance(item:Item) -> ItemInstance:
	var instance = ItemInstance.new()
	instance._id = "item-instance-" + UUID.generate()
	instance._item_id = item._id
	instance._stack_size = 1
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func create_item_category(name:String) -> ItemCategory:
	var instance = ItemCategory.new()
	instance._id = "item-category-" + UUID.generate()
	instance.name = name
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func create_inventory() -> Inventory:
	var instance = Inventory.new()
	instance._id = "inventory-" + UUID.generate()
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func save_item_instance(item_instance:ItemInstance) -> ItemInstance:
	PandoraSettings.get_current_backend().save_all([item_instance])
	return item_instance


func save_item(item:Item) -> Item:
	PandoraSettings.get_current_backend().save_all([item])
	return item


func save_item_category(category:ItemCategory) -> ItemCategory:
	PandoraSettings.get_current_backend().save_all([category])
	return category

func flush() -> void:
	PandoraSettings.get_current_backend().flush()
