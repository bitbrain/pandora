class_name CustomMockEntity extends PandoraEntity


func instantiate() -> PandoraEntityInstance:
	var instance_properties = _create_instance_properties()
	return CustomMockEntityInstance.new(get_entity_id(), instance_properties)
