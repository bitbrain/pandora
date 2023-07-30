class_name Inventory extends Node


signal item_added(item:ItemInstance, index:int)
signal item_removed(item:ItemInstance, index:int)


@export var size = 9
	

# id -> ItemInstance
var _slots = {}


func add_item(item:ItemInstance, index:int = -1) -> void:
	if index >= size:
		print("Index is out of bounds! Maximum index is ", (index - 1))
		return
	if index == -1:
		index = _find_next_index(item)
		if index == -1:
			print("No more space in inventory!")
			return
	if not _slots.has(index):
		_slots[index] = item
		item_added.emit(item, index)
	else:
		var existing_item = _slots[index] as ItemInstance
		if not existing_item.has_same_entity(item):
			print("Unable to add item! Slot ", index, " already occupied.")
			return
		var new_stacksize = existing_item.get_current_stacksize() + item.get_current_stacksize()
		if new_stacksize > existing_item.get_maximum_stacksize():
			print("Unable to add item! Too many items.")
			return
		existing_item.set_current_stacksize(new_stacksize)
		item_added.emit(existing_item, index)
		

func remove_item(index:int) -> ItemInstance:
	if _slots.has(index):
		var item = _slots[index]
		_slots.erase(index)
		item_removed.emit(item, index)
		return item
	print("No item to remove at index ", index)
	return null


func _find_next_index(item:ItemInstance) -> int:
	for i in range(0, size):
		if not _slots.has(i):
			return i
		var existing_item = _slots[i]
		if existing_item.has_same_entity(item):
			return i
	return -1
