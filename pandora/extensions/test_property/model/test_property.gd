class_name PandoraTestProperty extends RefCounted

var _item_name : String
var _quantity : int

func _init(item_name: String, quantity: int) -> void:
	_item_name = item_name
	_quantity = quantity

func set_item_name(item_name: String) -> void:
	_item_name = item_name

func set_quantity(quantity: int) -> void:
	_quantity = quantity

func get_item_name() -> String:
	return _item_name

func get_quantity() -> int:
	return _quantity

func load_data(data: Dictionary) -> void:
	if data.has("item_name"):
		_item_name = data["item_name"]
	if data.has("quantity"):
		_quantity = data["quantity"]

func save_data(fields_settings: Array[Dictionary]) -> Dictionary:
	var result := {}
	var itemNameIdx := fields_settings.find(func(dic: Dictionary): return dic["name"] == "Item Name")
	var quantityIdx := fields_settings.find(func(dic: Dictionary): return dic["name"] == "Quantity")
	if fields_settings[itemNameIdx]["enabled"]:
		result["item_name"] = _item_name
	if fields_settings[quantityIdx]["enabled"]:
		result["quantity"] = _quantity
	return result

func _to_string() -> String:
	return "<PandoraTestProperty>"
