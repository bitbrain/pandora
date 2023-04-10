class_name PandoraItemCategory extends PandoraIdentifiableWithDetails

var properties:PandoraCustomProperties

func load_data(data:Dictionary) -> void:
	super.load_data(data)
	properties = PandoraCustomProperties.new()
	properties.load_data(data["properties"])


func save_data() -> Dictionary:
	return DictionaryUtils.merge_dictionaries(super.save_data(), {
		"properties": properties.save_data()
	})
