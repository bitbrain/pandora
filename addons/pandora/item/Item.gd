## Data model for items
class_name Item extends PandoraIdentifiable

@export var name:String
@export var description:String
@export var icon_path:String
@export var maximum_stack_size = 99

var _category_id:String
var _properties:PandoraCustomProperties

func create_instance() -> ItemInstance:
	return Pandora.get_item_server().create_item_instance(self)
	

func get_category() -> ItemCategory:
	return Pandora.get_item_server().get_item_category_by_id(_category_id)
	

func is_type_of(category:ItemCategory) -> bool:
	return _category_id == category._id


func hash_value() -> int:
	return Hash.hash_attributes([_id, name, description, icon_path])


func load_data(data:Dictionary) -> void:
	super.load_data(data)
	name = data["name"]
	description = data["description"]
	icon_path = data["icon_path"]
	_category_id = data["_category_id"]


func save_data() -> Dictionary:
	return DictionaryUtils.merge_dictionaries(super.save_data(),
	{
		"name": name,
		"description": description,
		"icon_path":  icon_path,
		"_category_id": _category_id
	})
