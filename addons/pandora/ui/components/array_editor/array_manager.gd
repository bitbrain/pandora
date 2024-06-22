@tool
extends PanelContainer

const ArrayType = preload("res://addons/pandora/model/types/array.gd")
const ArrayItem = preload("res://addons/pandora/ui/components/array_editor/array_item.tscn")
const PropertyBarScene = "res://addons/pandora/ui/components/property_bar/property_bar.tscn"

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal item_updated(idx: int, new_item: Variant)
signal close_requested

@onready var close_button: Button = %CloseButton
@onready var new_item_button: Button = %NewItemButton
@onready var items_container: VBoxContainer = %ArrayItems
@onready var main_container: VBoxContainer = %MainContainer
var property_bar: Node

var _items: Array
var _property: PandoraProperty


func _ready():
	close_button.pressed.connect(func(): close_requested.emit())
	new_item_button.pressed.connect(_add_new_item)


func open(property: PandoraProperty):
	_property = property
	var property_bar_scene = load(PropertyBarScene)
	property_bar = property_bar_scene.instantiate()
	property_bar._ready()
	_load_items.call_deferred()


func close():
	_remove_empty_items()
	_clear()
	property_bar.queue_free()


func is_empty(item: Variant):
	var array_type = _property.get_setting(ArrayType.SETTING_ARRAY_TYPE)
	if array_type == "reference":
		return item == null
	if array_type == "resource":
		return is_instance_valid(item) == false
	elif array_type == "string":
		return item == ""
	else:
		return false


func _remove_empty_items():
	for index in range(_items.size()):
		if is_empty(_items[index]):
			_items.erase(index)
			item_removed.emit(_items[index])


func _clear():
	_items.clear()
	for child in items_container.get_children():
		child.queue_free()
	items_container.get_children().clear()


func _load_items():
	_clear()
	_items = _property.get_default_value().duplicate()
	var array_type = _property.get_setting(ArrayType.SETTING_ARRAY_TYPE)
	for i in range(_items.size()):
		var control = (
			property_bar.get_scene_by_type(array_type).instantiate() as PandoraPropertyControl
		)
		var item_property = PandoraProperty.new("", "array_item", array_type)
		item_property._setting_overrides = _property._setting_overrides
		var value = _items[i]
		if array_type == "resource":
			value = load(value)
		elif array_type == "reference":
			if value is Dictionary:
				value = Pandora.get_entity(value["_entity_id"])
			elif value is PandoraReference:
				value = value.get_entity()
		item_property.set_default_value(value)
		_add_property_control(control, item_property, i)


func _add_new_item():
	var array_type = _property.get_setting(ArrayType.SETTING_ARRAY_TYPE)
	var scene = property_bar.get_scene_by_type(array_type)
	var control = scene.instantiate() as PandoraPropertyControl
	var item_property = PandoraProperty.new(
		"", "array_item", _property.get_setting(ArrayType.SETTING_ARRAY_TYPE)
	)
	item_property._setting_overrides = _property._setting_overrides
	_items.append(item_property.get_default_value())
	_add_property_control(control, item_property, _items.size() - 1)
	item_added.emit(_items[_items.size() - 1])


func _add_property_control(
	control: PandoraPropertyControl, item_property: PandoraProperty, idx: int
):
	var item = ArrayItem.instantiate()

	control.init(item_property)

	control.property_value_changed.connect(func(value: Variant): item_updated.emit(idx, value))

	item.item_removal_requested.connect(
		func(): item_removed.emit(control._property.get_default_value())
	)
	item.init(_property, control, Pandora._entity_backend)
	items_container.add_child(item)
