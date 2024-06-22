@tool
extends PandoraPropertyControl

const ArrayType = preload("res://addons/pandora/model/types/array.gd")

@onready var array_editor = $ArrayEditor
var _items: Array = []


func _ready() -> void:
	refresh()
	_property.setting_changed.connect(_setting_changed)
	array_editor.item_added.connect(_on_item_added)
	array_editor.item_removed.connect(_on_item_removed)
	array_editor.item_updated.connect(_on_item_updated)


func refresh() -> void:
	if _property != null:
		array_editor.set_property(_property)
		_items = _property.get_default_value().duplicate()


func _on_item_added(item: Variant):
	_items.append(item)
	save_array()


func _on_item_updated(idx: int, item: Variant):
	if range(_items.size()).has(idx):
		_items[idx] = item
		save_array()
	else:
		_on_item_added(item)


func _on_item_removed(item: Variant):
	_items.erase(item)
	save_array()


func save_array():
	_property.set_default_value(_items)
	property_value_changed.emit(_items)


func _setting_changed(key: String):
	if key == ArrayType.SETTING_ARRAY_TYPE:
		_items.clear()
		save_array()
		refresh()
