class_name PandoraItemInstance extends PandoraIdentifiable

var _item_id:String
var _stack_size:int


func hash_value() -> int:
	return Hash.hash_attributes([_id, _item_id])

	
func get_item() -> PandoraItem:
	return Pandora.get_item_server().get_item_by_id(_item_id)


func load_data(data:Dictionary) -> void:
	super.load_data(data)
	_stack_size = data["_stack_size"]


func save_data() -> Dictionary:
	return DictionaryUtils.merge_dictionaries(super.save_data(),
	{
		"_stack_size": _stack_size
	})
