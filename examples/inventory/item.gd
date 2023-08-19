class_name Item extends PandoraEntity


func get_rarity() -> Rarity:
	return get_reference("Rarity") as Rarity


func get_maximum_stack_size() -> int:
	return get_integer("Maximum Stack Size")


func instantiate() -> PandoraEntityInstance:
	var instance_properties = _create_instance_properties()
	return ItemInstance.new(get_entity_id(), instance_properties)
