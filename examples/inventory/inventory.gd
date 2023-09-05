class_name Inventory extends Node


signal item_added(item:Item, index:int)
signal item_removed(item:Item, index:int)
	

# id -> ItemInstance
var _slots = {}


func add_item(item:Item, index:int) -> void:
	if not _slots.has(index):
		_slots[index] = item
		item_added.emit(item, index)
	else:
		var existing_item = _slots[index] as Item
		if not existing_item.has_same_entity(item):
			print("Unable to add item! Slot ", index, " already occupied.")
			return
		var new_stacksize = existing_item.get_current_stacksize() + item.get_current_stacksize()
		if new_stacksize > existing_item.get_maximum_stacksize():
			print("Unable to add item! Too many items.")
			return
		existing_item.set_current_stacksize(new_stacksize)
		item_added.emit(existing_item, index)
		

func remove_item(index:int) -> Item:
	if _slots.has(index):
		var item = _slots[index]
		_slots.erase(index)
		item_removed.emit(item, index)
		return item
	print("No item to remove at index ", index)
	return null
