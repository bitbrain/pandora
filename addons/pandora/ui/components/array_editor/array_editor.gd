@tool
extends HBoxContainer

signal item_added(item: Variant)
signal item_removed(item: Variant)
signal item_updated(idx: int, new_item: Variant)
signal about_to_popup

@onready var edit_button: Button = $EditArrayButton
@onready var array_info: LineEdit = $ArrayInfo
@onready var array_window: Window = $ArrayWindow

var _property: PandoraProperty

func _ready():
	_refresh()
	edit_button.pressed.connect(func(): array_window.open(_property))
	array_window.about_to_popup.connect(func(): about_to_popup.emit())
	array_window.item_added.connect(func(item: Variant): 
		item_added.emit(item)
		_refresh.call_deferred()
	)
	array_window.item_removed.connect(func(item: Variant): 
		item_removed.emit(item)
		_refresh.call_deferred()
	)
	array_window.item_updated.connect(func(idx: int, item: Variant): 
		item_updated.emit(idx, item)
		_refresh.call_deferred()
	)

func set_property(property: PandoraProperty):
	if property.get_original_category_id() != property._id:
		var original_category = Pandora.get_category(property.get_original_category_id())
		var original_array_property = original_category.get_entity_property(property.get_property_name())
		property._setting_overrides = original_array_property._setting_overrides
	_property = property
	_refresh()

func _refresh():
	if _property:
		var value = _property.get_default_value() as Array
		array_info.text = str(value.size()) + " Entries"
