class_name ItemInstance extends PandoraEntityInstance


func get_rarity() -> Rarity:
	return get_item().get_rarity()
	
	
func get_item() -> Item:
	return get_entity() as Item


func get_maximum_stacksize() -> int:
	return get_item().get_maximum_stack_size()
	
	
func get_current_stacksize() -> int:
	return get_integer("Current Stack Size")
	
	
func set_current_stacksize(stack_size:int) -> void:
	set_integer("Current Stack Size", stack_size)
