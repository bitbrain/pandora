class_name PandoraDependencyProperty extends RefCounted

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
	_item_name = data["item_name"]
	_quantity = data["quantity"]

func save_data() -> Dictionary:
	return { "item_name": _item_name, "quantity": _quantity }

func _to_string() -> String:
	return "<PandoraDependencyProperty [ " + _item_name + " ]>"
