@tool
extends PanelContainer

const ArrayType = preload("res://addons/pandora/model/types/array.gd")
const ArrayItem = preload("res://addons/pandora/ui/components/array_editor/array_item.tscn")

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal item_updated(previous: Variant, current: Variant)
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
	_items = property.get_default_value() as Array
	# This looks spooky..
	property_bar = get_node("../../../../../../../../../../PanelContainer/MarginContainer/HBoxContainer/PropertyBar")

func close():
	pass

func _add_new_item():
	print(property_bar)
	var array_type = _property.get_setting(ArrayType.SETTING_ARRAY_TYPE)
	var scene = property_bar.get_scene_by_type(array_type)
	var control = scene.instantiate() as PandoraPropertyControl
	_add_property_control(control)

func _add_property_control(control:PandoraPropertyControl):
	var item = ArrayItem.instantiate()
	item.init(_property, control, Pandora._entity_backend)
	items_container.add_child(item)
