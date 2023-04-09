class_name ItemCategory extends PandoraIdentifiable

@export var name:String
@export var description:String
@export var icon_path:String

var properties:PandoraCustomProperties

func load_data(data:Dictionary) -> void:
	super.load_data(data)
	name = data["name"]
	description = data["description"]
	icon_path = data["icon_path"]
	properties = PandoraCustomProperties.new()
	properties.load_data(data["properties"])


func save_data() -> Dictionary:
	return DictionaryUtils.merge_dictionaries(super.save_data(), {
		"name": name,
		"description": description,
		"icon_path": icon_path,
		"properties": properties.save_data()
	})
