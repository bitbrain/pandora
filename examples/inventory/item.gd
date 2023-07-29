class_name Item extends PandoraEntity


func get_rarity() -> Rarity:
	return get_entity_property("Rarity").get_default_value() as Rarity


func get_maximum_stack_size() -> int:
	return get_entity_property("Maximum Stack Size").get_default_value()


func instantiate() -> PandoraEntityInstance:
	var instance_properties = _create_instance_properties()
	return ItemInstance.new(get_entity_id(), instance_properties)
