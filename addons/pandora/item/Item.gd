## Data model for items
class_name PandoraItem extends PandoraIdentifiableWithDetails

@export var maximum_stack_size = 99

var _category_id:String
var _properties:PandoraCustomProperties

func create_instance() -> PandoraItemInstance:
	return Pandora.get_item_server().create_item_instance(self)


func get_category() -> PandoraItemCategory:
	return Pandora.get_item_server().get_item_category_by_id(_category_id)
	

func is_type_of(category:PandoraItemCategory) -> bool:
	return _category_id == category._id


func load_data(data:Dictionary) -> void:
	super.load_data(data)
	_category_id = data["_category_id"]


func save_data() -> Dictionary:
	return DictionaryUtils.merge_dictionaries(super.save_data(),
	{
		"_category_id": _category_id
	})
