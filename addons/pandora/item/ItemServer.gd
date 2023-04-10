@tool
class_name PandoraItemServer extends Node


const UUID = preload("res://addons/pandora/utils/UUID.gd")


func get_item_instance_by_id(id:String) -> PandoraItemInstance:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as PandoraItemInstance
	else:
		return null
	

func get_item_by_id(id:String) -> PandoraItem:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as PandoraItem
	else:
		return null


func get_inventory_by_id(id:String) -> PandoraInventory:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as PandoraInventory
	else:
		return null
	
	
func get_category_by_id(id:String) -> PandoraItemCategory:
	var entities = PandoraSettings.get_current_backend().load_by_ids([id])
	if not entities.is_empty():
		return entities[id] as PandoraItemCategory
	else:
		return null


func create_item(name:String) -> PandoraItem:
	var instance = PandoraItem.new()
	instance._id = "item-" + UUID.generate()
	instance.maximum_stack_size = -1 #infinite
	instance.name = name
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func create_item_instance(item:PandoraItem) -> PandoraItemInstance:
	var instance = PandoraItemInstance.new()
	instance._id = "item-instance-" + UUID.generate()
	instance._item_id = item._id
	instance._stack_size = 1
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func create_item_category(name:String) -> PandoraItemCategory:
	var instance = PandoraItemCategory.new()
	instance._id = "item-category-" + UUID.generate()
	instance.name = name
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func create_inventory() -> PandoraInventory:
	var instance = PandoraInventory.new()
	instance._id = "inventory-" + UUID.generate()
	PandoraSettings.get_current_backend().save_all([instance])
	return instance


func save_item_instance(item_instance:PandoraItemInstance) -> PandoraItemInstance:
	PandoraSettings.get_current_backend().save_all([item_instance])
	return item_instance


func save_item(item:PandoraItem) -> PandoraItem:
	PandoraSettings.get_current_backend().save_all([item])
	return item


func save_item_category(category:PandoraItemCategory) -> PandoraItemCategory:
	PandoraSettings.get_current_backend().save_all([category])
	return category

func flush() -> void:
	PandoraSettings.get_current_backend().flush()
