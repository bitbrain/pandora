extends Node

static func create_from_data_type(data_type:String) -> PandoraIdentifiable:
	if PandoraItem.get_data_type() == data_type:
		return PandoraItem.new()
	if PandoraItemInstance.get_data_type() == data_type:
		return PandoraItemInstance.new()
	if PandoraItemCategory.get_data_type() == data_type:
		return PandoraItemCategory.new()
	return null
