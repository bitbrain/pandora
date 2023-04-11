@tool
class_name PandoraItemServer extends Node


const UUID = preload("res://addons/pandora/utils/UUID.gd")

var static_cache: PandoraCache
var dynamic_cache: PandoraCache

func create_item(name: String) -> PandoraItem:
	var item = PandoraItem.new()
	item.name = name
	item._id = _generate_id(item)
	static_cache.set_entry(item.get_id(), item, item.get_data_type())
	return item


func create_item_instance(item_id: String) -> PandoraItemInstance:
	var item_instance = PandoraItemInstance.new()
	item_instance._item_id = item_id
	item_instance._id = _generate_id(item_instance)
	dynamic_cache.set_entry(item_instance.get_id(), item_instance, item_instance.get_data_type())
	return item_instance
	
	
func update_item(item: PandoraItem) -> void:
	static_cache.set_entry(item.get_id(), item, item.get_data_type())


func remove_item(item_id: String) -> void:
	static_cache.delete_entry(item_id, _get_data_type_from_id(item_id))


func update_item_instance(item_instance: PandoraItemInstance) -> void:
	dynamic_cache.set_entry(item_instance.get_id(), item_instance, item_instance.get_data_type())


func remove_item_instance(item_instance_id: String) -> void:
	dynamic_cache.delete_entry(item_instance_id, _get_data_type_from_id(item_instance_id))


func _generate_id(serializable:PandoraSerializable) -> String:
	return serializable.get_data_type() + "-" + UUID.generate()
	

func _get_data_type_from_id(id:String) -> String:
	return id.split("-")[0]
